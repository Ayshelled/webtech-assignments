require "test_helper"

class NotificationsMailerTest < ActionMailer::TestCase
  setup do
    @host = User.create!(full_name: "Hannah Host", email_address: "host@example.com", password: "password123")
    @seeker = User.create!(full_name: "Sam Seeker", email_address: "seeker@example.com", password: "password123")
    neighborhood = Neighborhood.create!(name: "Ñuñoa", city: "Santiago")
    property = Property.create!(user: @host, neighborhood: neighborhood, street_address: "Irarrázaval 2450",
                                property_type: :apartment)
    listing = property.listings.create!(title: "Room in Ñuñoa", monthly_rent: 350_000, deposit: 0,
                                        available_from: Date.current + 10, description: "<p>A room</p>",
                                        status: :published)
    @application = listing.applications.create!(user: @seeker, message: "Hi, I'm Sam", intended_stay_months: 6,
                                                desired_move_in_date: Date.current + 15)
  end

  test "new application goes to the host" do
    mail = NotificationsMailer.with(application: @application).new_application

    assert_equal [ "host@example.com" ], mail.to
    assert_equal "New application for Room in Ñuñoa", mail.subject
    assert_match "Sam Seeker", mail.text_part.body.to_s
    assert_match "/applications/#{@application.id}", mail.text_part.body.to_s
  end

  test "answered application goes to the seeker, with a subject for each answer" do
    @application.update!(status: :shortlisted)
    mail = NotificationsMailer.with(application: @application).application_answered

    assert_equal [ "seeker@example.com" ], mail.to
    assert_equal "You are on the shortlist for Room in Ñuñoa", mail.subject
    assert_match "shortlisted your application", mail.text_part.body.to_s
  end
end
