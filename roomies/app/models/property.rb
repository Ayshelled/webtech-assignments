class Property < ApplicationRecord
  belongs_to :user # the host
  belongs_to :neighborhood
  has_many :listings, dependent: :destroy
  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities
  has_many :reviews, through: :listings

  enum :property_type, {
    apartment: "apartment", house: "house", studio: "studio", townhouse: "townhouse"
  }, validate: true

  scope :with_published_listings, -> { where(id: Listing.published.select(:property_id)) }

  validates :street_address, presence: true, length: { maximum: 200 }
  validates :bedrooms_count, :bathrooms_count,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end
