class ListingPhoto < ApplicationRecord
  belongs_to :listing

  # Uploaded photographs. Named variants keep the cards and thumbnails from
  # downloading the full-resolution file: only the listing page asks for :large.
  has_one_attached :image do |attachable|
    attachable.variant :card,  resize_to_fill:  [ 600, 400 ]
    attachable.variant :thumb, resize_to_fill:  [ 400, 300 ]
    attachable.variant :large, resize_to_limit: [ 1600, 1200 ]
  end

  # Preloads the uploaded file and its generated variants, so a page of cards doesn't run a query per photo
  WITH_IMAGE = { image_attachment: { blob: { variant_records: { image_attachment: :blob } } } }.freeze

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

  # Uploaded photos get a description from their listing, so they are never left without alt text
  before_validation :describe_uploaded_photo, if: -> { alt_text.blank? && image.attached? }

  # What image_tag receives: the requested variant of the uploaded file, or the
  # external URL of a photo that was never uploaded (seed data from Assignment 2)
  def source(variant)
    image.attached? ? image.variant(variant) : image_url
  end

  private

  def describe_uploaded_photo
    self.alt_text = "Photo of #{listing&.title.presence || "the room"}"
  end

  def image_type_is_accepted
    return if ACCEPTED_IMAGE_TYPES.include?(image.content_type)

    errors.add(:image, "must be a JPEG, PNG, or WebP image")
  end

  def image_size_is_within_limit
    return unless image.byte_size > MAX_IMAGE_SIZE

    errors.add(:image, "must be smaller than or equal to 10 MB")
  end
end
