# Sign up. The generator doesn't create it: a new account is always a member
# (role is not a permitted parameter) and starts signed in.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  # No record to authorize: signing in, signing up and the landing page are open to everyone
  skip_after_action :verify_authorized
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome to Roomies, #{@user.full_name}!"
    else
      render_invalid :new, @user
    end
  end

  private

  def registration_params
    params.expect(user: %i[full_name email_address phone password password_confirmation])
  end
end
