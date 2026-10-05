class Listing < ApplicationRecord
  belongs_to :property
  has_one :neighborhood, through: :property
  has_one :host, through: :property, source: :user
  has_many :listing_photos, -> { order(:position) }, dependent: :destroy
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

  validates :monthly_rent, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stay_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :available_from, presence: true
  validates :description, presence: true
  validates :furnished, :private_bathroom, inclusion: { in: [true, false] }
  validate :available_from_cannot_be_in_the_past, if: :will_save_change_to_available_from?

  private

  def available_from_cannot_be_in_the_past
    return if available_from.blank? || available_from >= Date.current

    errors.add(:available_from, "can't be in the past")
  end
end
