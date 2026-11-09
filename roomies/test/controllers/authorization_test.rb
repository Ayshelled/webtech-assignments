require "test_helper"

# Every action is blocked in the controller, not only hidden in the interface, and an
# unauthorized attempt lands on the 403 page instead of a raw error
class AuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    @host     = create_member("host")
    @seeker   = create_member("seeker")
    @stranger = create_member("stranger")
    @listing  = create_listing(@host)
    @application = create_application(@listing, @seeker)
  end

  test "an application can't be reached by typing its id in the URL" do
    sign_in_as @stranger
    get application_path(@application)

    assert_response :forbidden
    assert_select "h1", "You can't do that in Roomies"
    assert_match "belongs to someone else", response.body
  end

  test "the seeker and the host can open the application" do
    sign_in_as @seeker
    get application_path(@application)
    assert_response :success

    sign_out
    sign_in_as @host
    get application_path(@application)
    assert_response :success
  end

  test "another member can't answer an application, even sending the request by hand" do
    sign_in_as @stranger
    patch accept_application_path(@application)

    assert_response :forbidden
    assert_predicate @application.reload, :pending?
  end

  test "another member can't edit or delete someone else's listing" do
    sign_in_as @stranger
    get edit_listing_path(@listing)
    assert_response :forbidden

    assert_no_difference -> { Listing.count } do
      delete listing_path(@listing)
    end
    assert_response :forbidden
  end

  test "a visitor sees published listings, but not a draft" do
    draft = create_listing(@host, status: :draft)
    get listing_path(@listing)
    assert_response :success

    get listing_path(draft)
    assert_response :forbidden
  end

  test "the inbox lists only the applications received by the host's rooms" do
    other_listing = create_listing(@stranger, title: "Other host room")
    create_application(other_listing, create_member("someone"))

    sign_in_as @host
    get applications_path
    assert_response :success
    assert_match @listing.title, response.body
    assert_no_match "Other host room", response.body
  end

  test "only moderators manage neighborhoods" do
    sign_in_as @stranger
    get new_neighborhood_path
    assert_response :forbidden

    sign_out
    sign_in_as create_member("mod", role: :moderator)
    get new_neighborhood_path
    assert_response :success
  end

  test "a member reports a listing and a moderator upholds it" do
    sign_in_as @stranger
    assert_difference -> { Report.count } do
      post listing_reports_path(@listing), params: { report: { reason: "misleading", details: "Photos are not real" } }
    end

    patch uphold_report_path(Report.last)
    assert_response :forbidden

    sign_out
    sign_in_as create_member("mod", role: :moderator)
    patch uphold_report_path(Report.last)
    assert_predicate Report.last, :actioned?
    assert_predicate @listing.reload, :withdrawn?
  end
end
