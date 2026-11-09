require "test_helper"

class Api::V1::ListingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = create_member("host")
    @cheap     = create_listing(@host, title: "Cheap room", rent: 250_000)
    @expensive = create_listing(@host, title: "Expensive room", rent: 600_000)
    @draft     = create_listing(@host, title: "Draft room", status: :draft)
  end

  test "lists the published rooms with data and meta" do
    get api_v1_listings_path

    assert_response :ok
    body = response.parsed_body
    assert_equal [ "Cheap room", "Expensive room" ].sort, body["data"].map { |listing| listing["title"] }.sort
    assert_equal 2, body["meta"]["total_count"]
    assert_equal 1, body["meta"]["page"]
  end

  test "filters by maximum rent" do
    get api_v1_listings_path(max_rent: 300_000)

    assert_equal [ "Cheap room" ], response.parsed_body["data"].map { |listing| listing["title"] }
  end

  test "exposes no personal data" do
    get api_v1_listing_path(@cheap)

    assert_response :ok
    json = response.body
    assert_no_match @host.email_address, json
    assert_no_match @host.full_name, json
    assert_no_match @cheap.property.street_address, json
  end

  test "a draft is not found" do
    get api_v1_listing_path(@draft)

    assert_response :not_found
    assert_equal 404, response.parsed_body["error"]["status"]
  end

  test "a malformed filter is a 400 that names the parameter" do
    get api_v1_listings_path(max_rent: "cheap", available_by: "tomorrow")

    assert_response :bad_request
    assert_equal %w[available_by max_rent], response.parsed_body["error"]["details"].keys.sort
  end

  test "paginates" do
    get api_v1_listings_path(per_page: 1, sort: "rent_asc")

    body = response.parsed_body
    assert_equal [ "Cheap room" ], body["data"].map { |listing| listing["title"] }
    assert_equal 2, body["meta"]["total_pages"]
    assert_not_nil body["links"]["next"]
  end
end
