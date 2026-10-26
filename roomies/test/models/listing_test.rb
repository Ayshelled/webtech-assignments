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

  test "description and house rules keep their rich text formatting" do
    listing = Listing.new(description: "<p><strong>Bright</strong> room</p>",
                          house_rules: "<ul><li>No smoking</li></ul>")

    assert_includes listing.description.body.to_html, "<strong>Bright</strong>"
    assert_includes listing.house_rules.body.to_html, "<li>No smoking</li>"
  end

  test "a description with no text is blank" do
    listing = Listing.new(description: "<p><br></p>")

    assert_not listing.valid?
    assert_includes listing.errors[:description], "can't be blank"
  end

  test "a listing is created as a draft that only its host sees" do
    listing = saved_listing
    other = User.create!(full_name: "Seeker", email_address: "seeker@example.com", password: "password123")

    assert_predicate listing, :draft?
    assert listing.visible_to?(listing.property.user)
    assert_not listing.visible_to?(other)
    assert_not listing.visible_to?(nil)
  end

  test "the host publishes, withdraws and rents along the lifecycle only" do
    listing = saved_listing
    error = assert_raises(ActiveRecord::RecordInvalid) { listing.mark_rented! }
    assert_match "can't change from draft to rented", error.message

    listing.reload.publish!
    assert_predicate listing, :published?
    listing.withdraw!
    assert_predicate listing, :withdrawn?
    listing.publish!
    listing.update!(status: :reserved) # what accepting an applicant does
    listing.mark_rented!
    assert_predicate listing, :rented?
    assert_raises(ActiveRecord::RecordInvalid) { listing.publish! }
  end

  private

  def upload(name, content_type)
    Rack::Test::UploadedFile.new(file_fixture(name), content_type)
  end

  def saved_listing
    host = User.create!(full_name: "Host", email_address: "host@example.com", password: "password123")
    property = Property.create!(user: host, neighborhood: Neighborhood.create!(name: "Ñuñoa", city: "Santiago"),
                                street_address: "Irarrázaval 2450", property_type: :house)
    property.listings.create!(title: "Room in Ñuñoa", monthly_rent: 350_000, deposit: 0,
                              available_from: Date.current + 10, description: "<p>A room</p>")
  end
end
