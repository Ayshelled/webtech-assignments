require "test_helper"

# The notification emails are delivered through Active Job (deliver_later)
class ApplicationNotificationsTest < ActionDispatch::IntegrationTest
  setup do
    @host = new_user("host")
    neighborhood = Neighborhood.create!(name: "Ñuñoa", city: "Santiago")
    property = Property.create!(user: @host, neighborhood: neighborhood, street_address: "Irarrázaval 2450",
                                property_type: :apartment)
    @listing = property.listings.create!(title: "Room in Ñuñoa", monthly_rent: 350_000, deposit: 0,
                                         available_from: Date.current + 10, description: "<p>A room</p>",
                                         status: :published)
  end

  test "applying enqueues an email to the host" do
    sign_in_as new_user("seeker")

    assert_enqueued_emails 1 do
      post listing_applications_path(@listing), params: { application: {
        message: "Hi!", desired_move_in_date: Date.current + 15, intended_stay_months: 6 } }
    end

    perform_enqueued_jobs
    assert_equal [ "host@example.com" ], ActionMailer::Base.deliveries.last.to
  end

  test "accepting emails the accepted seeker and every seeker rejected automatically" do
    chosen = apply("chosen")
    other  = apply("other")
    sign_in_as @host

    perform_enqueued_jobs do
      patch accept_application_path(chosen)
    end

    subjects = ActionMailer::Base.deliveries.to_h { |mail| [ mail.to.first, mail.subject ] }
    assert_equal "Your application for Room in Ñuñoa was accepted", subjects["chosen@example.com"]
    assert_equal "News about your application for Room in Ñuñoa", subjects["other@example.com"]
    assert_predicate other.reload, :rejected?
  end

  private

  def new_user(name)
    User.create!(full_name: name.capitalize, email_address: "#{name}@example.com", password: "password123")
  end

  def apply(name)
    @listing.applications.create!(user: new_user(name), message: "Hi, I'm #{name}", intended_stay_months: 6,
                                  desired_move_in_date: Date.current + 15)
  end
end
