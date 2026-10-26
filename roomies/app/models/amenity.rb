class Amenity < ApplicationRecord
  has_many :property_amenities, dependent: :destroy
  has_many :properties, through: :property_amenities

  # "Wi-Fi " is saved as "Wi-Fi", so it can't sneak past the uniqueness check
  normalizes :name, with: ->(value) { value.squish }

  enum :category, { amenity: "amenity", shared_space: "shared_space" }, validate: true

  scope :alphabetical, -> { order(:name) }

  validates :name, presence: true, length: { maximum: 60 },
                   uniqueness: { case_sensitive: false }
end
