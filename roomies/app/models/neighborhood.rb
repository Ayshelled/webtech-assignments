class Neighborhood < ApplicationRecord
  has_many :properties, dependent: :restrict_with_error
  has_many :listings, through: :properties

  # " providencia " is saved as "providencia": no leading, trailing or double spaces
  normalizes :name, :city, with: ->(value) { value.squish }

  scope :alphabetical, -> { order(:city, :name) }

  validates :name, presence: true, length: { maximum: 100 }
  validates :city, presence: true, length: { maximum: 100 }
  validate :name_unique_in_city

  private

  # Case-insensitive on both columns: "providencia, santiago" is the same
  # neighborhood as "Providencia, Santiago". The database enforces it too,
  # with a unique index on lower(name), lower(city).
  def name_unique_in_city
    return if name.blank? || city.blank?

    duplicate = Neighborhood.where.not(id: id)
                            .where("LOWER(name) = LOWER(?) AND LOWER(city) = LOWER(?)", name, city)
    errors.add(:name, "already exists in #{city}") if duplicate.exists?
  end
end
