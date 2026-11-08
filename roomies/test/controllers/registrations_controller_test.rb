require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "sign up creates a member and signs them in" do
    assert_difference -> { User.count } do
      post sign_up_path, params: { user: { full_name: "New Member", email_address: "new@example.com",
                                           password: "password123", password_confirmation: "password123" } }
    end

    assert_redirected_to root_url
    assert_predicate User.find_by(email_address: "new@example.com"), :member?
    assert cookies[:session_id]
  end

  test "sign up with errors renders the form again" do
    assert_no_difference -> { User.count } do
      post sign_up_path, params: { user: { full_name: "", email_address: "bad", password: "short", password_confirmation: "short" } }
    end

    assert_response :unprocessable_content
  end
end
