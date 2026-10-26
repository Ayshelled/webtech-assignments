class Listing < ApplicationRecord
  belongs_to :property
  has_one :neighborhood, through: :property
  has_one :host, through: :property, source: :user
  # Photos are saved together with the listing form (new uploads and removals).
  # They are validated by uploaded_photos_must_be_valid, which names the bad file.
  has_many :listing_photos, -> { order(:position) }, dependent: :destroy, inverse_of: :listing,
                            autosave: true, validate: false
  has_many :applications, dependent: :destroy
  has_many :applicants, through: :applications, source: :user
  has_many :visits, through: :applications
  has_many :reviews, through: :visits
  has_many :saved_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  # Lifecycle: draft -> published -> reserved -> rented; withdrawn from draft or published.
  # The enum also gives the scopes Listing.published, Listing.draft, etc.
  enum :status, {
    draft: "draft", published: "published", reserved: "reserved",
    rented: "rented", withdrawn: "withdrawn"
  }, validate: true

  scope :in_neighborhood, ->(neighborhood_id) {
    where(property_id: Property.where(neighborhood_id: neighborhood_id).select(:id))
  }
  scope :under_rent,   ->(max_rent) { where(monthly_rent: ..max_rent) }
  # Rooms you can move into on that date: already available on it or before
  scope :available_by, ->(date) { where(available_from: ..date) }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :with_amenity, ->(amenity_id) {
    where(property_id: PropertyAmenity.where(amenity_id: amenity_id).select(:property_id))
  }

  validates :title, presence: true, length: { maximum: 100 }
  validates :monthly_rent, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stay_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :available_from, presence: true
  validates :description, presence: true
  validates :furnished, :private_bathroom, inclusion: { in: [true, false] }
  validate :available_from_cannot_be_in_the_past, if: :will_save_change_to_available_from?
  validate :uploaded_photos_must_be_valid
  validate :photos_within_limit

  MAX_PHOTOS = 10

  # Files uploaded from the listing form: each one becomes a photo after the last one
  def new_photos=(files)
    position = listing_photos.map(&:position).max.to_i
    position += 1 if listing_photos.any?

    Array(files).compact_blank.each do |file|
      listing_photos.build(image: file, position: position)
      position += 1
    end
  end

  # Photos the host ticked to remove when editing; they are deleted when the listing saves
  def remove_photo_ids=(ids)
    ids = Array(ids).compact_blank.map(&:to_i)
    listing_photos.each { |photo| photo.mark_for_destruction if ids.include?(photo.id) }
  end

  # First photo by position; uses the preloaded photos when the controller includes them
  def cover_photo
    listing_photos.first
  end

  private

  def uploaded_photos_must_be_valid
    listing_photos.select { |photo| photo.new_record? || photo.changed? }.each do |photo|
      next if photo.marked_for_destruction? || photo.valid?

      name = photo.image.attached? ? photo.image.filename.to_s : "A photo"
      photo.errors.each { |error| errors.add(:photos, "#{name}: #{error.full_message.downcase_first}") }
    end
  end

  def photos_within_limit
    kept = listing_photos.reject(&:marked_for_destruction?).size
    errors.add(:photos, "can't be more than #{MAX_PHOTOS} (this listing would have #{kept})") if kept > MAX_PHOTOS
  end

  def available_from_cannot_be_in_the_past
    return if available_from.blank? || available_from >= Date.current

    errors.add(:available_from, "can't be in the past")
  end
end
