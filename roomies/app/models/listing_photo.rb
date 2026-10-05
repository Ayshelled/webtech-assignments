class ListingPhoto < ApplicationRecord
  belongs_to :listing

  validates :image_url, presence: true, length: { maximum: 500 },
                        format: { with: %r{\Ahttps?://\S+\z}, message: "must be an http(s) URL" }
  validates :alt_text, presence: true, length: { maximum: 255 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :caption, length: { maximum: 150 }
end
