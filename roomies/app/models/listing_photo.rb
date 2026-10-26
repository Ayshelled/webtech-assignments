class ListingPhoto < ApplicationRecord
  belongs_to :listing
  has_one_attached :image

  MAX_IMAGE_SIZE = 10.megabytes
  ACCEPTED_IMAGE_TYPES = %w[image/jpeg image/png image/webp].freeze

  validates :image_url, presence: true, length: { maximum: 500 },
                        format: { with: %r{\Ahttps?://\S+\z}, message: "must be an http(s) URL" },
                        unless: -> { image.attached? }
  validates :alt_text, presence: true, length: { maximum: 255 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :caption, length: { maximum: 150 }
  validate :image_type_is_accepted, if: -> { image.attached? }
  validate :image_size_is_within_limit, if: -> { image.attached? }

  private

  def image_type_is_accepted
    return if ACCEPTED_IMAGE_TYPES.include?(image.content_type)

    errors.add(:image, "must be a JPEG, PNG, or WebP image")
  end

  def image_size_is_within_limit
    return unless image.byte_size > MAX_IMAGE_SIZE

    errors.add(:image, "must be smaller than or equal to 10 MB")
  end
end
