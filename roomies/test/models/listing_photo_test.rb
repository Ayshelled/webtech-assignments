require "test_helper"

class ListingPhotoTest < ActiveSupport::TestCase
  test "accepts a legacy image URL" do
    assert_predicate listing_photo, :valid?
  end

  test "accepts an attached image without a legacy URL" do
    photo = listing_photo(image_url: nil)
    attach_image(photo, content_type: "image/webp")

    assert_predicate photo, :valid?
  end

  test "rejects an attached file that is not an accepted image type" do
    photo = listing_photo(image_url: nil)
    attach_image(photo, content_type: "text/plain")

    assert_not photo.valid?
    assert_includes photo.errors[:image], "must be a JPEG, PNG, or WebP image"
  end

  test "rejects an attached image larger than 10 MB" do
    photo = listing_photo(image_url: nil)
    attach_image(photo, content_type: "image/jpeg", size: ListingPhoto::MAX_IMAGE_SIZE + 1)

    assert_not photo.valid?
    assert_includes photo.errors[:image], "must be smaller than or equal to 10 MB"
  end

  test "requires either an attached image or a legacy URL" do
    photo = listing_photo(image_url: nil)

    assert_not photo.valid?
    assert_includes photo.errors[:image_url], "can't be blank"
  end

  private

  def listing_photo(image_url: "https://example.com/room.jpg")
    ListingPhoto.new(
      listing: Listing.new,
      image_url: image_url,
      alt_text: "A bright room",
      position: 0
    )
  end

  def attach_image(photo, content_type:, size: 1)
    photo.image.attach(
      io: StringIO.new("x" * size),
      filename: "room.jpg",
      content_type: content_type,
      identify: false
    )
  end
end
