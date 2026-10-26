require "test_helper"

class ListingTest < ActiveSupport::TestCase
  test "uploaded files become photos in order, with alt text from the title" do
    listing = Listing.new(title: "Room in Ñuñoa")
    listing.new_photos = [ "", upload("room.png", "image/png"), upload("room.png", "image/png") ]

    assert_equal [ 0, 1 ], listing.listing_photos.map(&:position)
    listing.valid?
    assert_empty listing.errors[:photos]
    assert_equal "Photo of Room in Ñuñoa", listing.listing_photos.first.alt_text
  end

  test "a file that is not an image is reported on the photos field" do
    listing = Listing.new(title: "Room in Ñuñoa")
    listing.new_photos = [ upload("notes.txt", "text/plain") ]

    assert_not listing.valid?
    assert_match "notes.txt", listing.errors[:photos].first
  end

  test "a listing can't have more than the maximum number of photos" do
    listing = Listing.new(title: "Room in Ñuñoa")
    listing.new_photos = Array.new(Listing::MAX_PHOTOS + 1) { upload("room.png", "image/png") }

    assert_not listing.valid?
    assert_match "can't be more than #{Listing::MAX_PHOTOS}", listing.errors[:photos].join
  end

  private

  def upload(name, content_type)
    Rack::Test::UploadedFile.new(file_fixture(name), content_type)
  end
end
