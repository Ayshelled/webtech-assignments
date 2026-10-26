require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  setup do
    @host = user("host")
    neighborhood = Neighborhood.create!(name: "Ñuñoa", city: "Santiago")
    property = Property.create!(user: @host, neighborhood: neighborhood, street_address: "Irarrázaval 2450",
                                property_type: :apartment)
    @listing = property.listings.create!(title: "Room in Ñuñoa", monthly_rent: 350_000, deposit: 0,
                                         available_from: Date.current + 10, description: "<p>A room</p>",
                                         status: :published)
    @chosen  = apply("chosen")
    @pending = apply("pending")
    @shortlisted = apply("shortlisted", :shortlisted)
    @withdrawn = apply("withdrawn", :withdrawn)
  end

  test "accepting rejects every other pending or shortlisted application and reserves the listing" do
    rejected = @chosen.accept!

    assert_predicate @chosen.reload, :accepted?
    assert_equal [ @pending, @shortlisted ].sort_by(&:id), rejected.sort_by(&:id)
    assert_predicate @pending.reload, :rejected?
    assert_predicate @shortlisted.reload, :rejected?
    assert_predicate @withdrawn.reload, :withdrawn?
    assert_predicate @listing.reload, :reserved?
  end

  test "if any effect of accepting fails, nothing changes" do
    # A listing without description can't be saved, so reserving it fails
    ActionText::RichText.where(record: @listing).delete_all

    assert_raises(ActiveRecord::RecordInvalid) { Application.find(@chosen.id).accept! }

    assert_predicate @chosen.reload, :pending?
    assert_predicate @pending.reload, :pending?
    assert_predicate @shortlisted.reload, :shortlisted?
    assert_predicate @listing.reload, :published?
  end

  test "a reserved listing takes no more answers nor applications" do
    @chosen.accept!

    error = assert_raises(ActiveRecord::RecordInvalid) { @withdrawn.reload.accept! }
    assert_match "no longer takes answers", error.message
    assert_not Application.new(listing: @listing.reload, user: user("late"), message: "Hi",
                               desired_move_in_date: Date.current + 20, intended_stay_months: 6).valid?
  end

  test "a listing has at most one accepted application" do
    @chosen.update!(status: :accepted)
    @pending.status = :accepted

    assert_not @pending.valid?
    assert_includes @pending.errors[:base], "This room already has an accepted application"
  end

  test "an application can only be withdrawn while pending or shortlisted" do
    assert @shortlisted.update(status: :withdrawn)

    @chosen.update!(status: :rejected)
    assert_not @chosen.update(status: :withdrawn)
    assert_includes @chosen.errors[:status], "can't change from rejected to withdrawn"
  end

  test "shortlisting moves a pending application forward, never back" do
    @pending.shortlist!
    assert_predicate @pending.reload, :shortlisted?

    assert_raises(ActiveRecord::RecordInvalid) { @withdrawn.shortlist! }
  end

  private

  def user(name)
    User.create!(full_name: name.capitalize, email_address: "#{name}@example.com", password: "password123")
  end

  def apply(name, status = :pending)
    Application.create!(listing: @listing, user: user(name), status: status, message: "Hi, I'm #{name}",
                        desired_move_in_date: Date.current + 15, intended_stay_months: 6)
  end
end
