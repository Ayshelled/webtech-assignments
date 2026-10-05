class ListingPhoto < ApplicationRecord
  belongs_to :listing

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :caption, length: { maximum: 150 }
  validates :alt_text, length: { maximum: 255 }
end
