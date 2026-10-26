require "test_helper"

class VisitTest < ActiveSupport::TestCase
  setup do
    host = User.create!(full_name: "Host", email_address: "host@example.com", password: "password123")
    seeker = User.create!(full_name: "Seeker", email_address: "seeker@example.com", password: "password123")
    property = Property.create!(user: host, neighborhood: Neighborhood.create!(name: "Ñuñoa", city: "Santiago"),
                                street_address: "Irarrázaval 2450", property_type: :house)
    listing = property.listings.create!(title: "Room in Ñuñoa", monthly_rent: 350_000, deposit: 0, status: :published,
                                        available_from: Date.current + 10, description: "<p>A room</p>")
    @application = Application.create!(listing: listing, user: seeker, message: "Hi",
                                       desired_move_in_date: Date.current + 15, intended_stay_months: 6)
  end

  test "a visit can only be proposed on a shortlisted application" do
    visit = @application.visits.new(scheduled_at: 2.days.from_now)
    assert_not visit.valid?
    assert_match "shortlisted", visit.errors[:base].first

    @application.shortlist!
    assert @application.visits.new(scheduled_at: 2.days.from_now).valid?
  end

  test "a visit can't be scheduled in the past" do
    @application.shortlist!
    visit = @application.visits.new(scheduled_at: 1.hour.ago)

    assert_not visit.valid?
    assert_includes visit.errors[:scheduled_at], "can't be in the past"
  end

  test "only a confirmed visit can be completed, and completed is final" do
    @application.shortlist!
    visit = @application.visits.create!(scheduled_at: 2.days.from_now)

    assert_not visit.update(status: :completed)
    visit.update!(status: :confirmed)
    visit.update!(status: :completed)
    assert_not visit.update(status: :cancelled)
  end
end
