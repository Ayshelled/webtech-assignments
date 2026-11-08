# The signed-in member's own profile: there is no id in the URL, so nobody
# can open or change someone else's
class ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Your profile was updated."
    else
      render_invalid :edit, @user
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.expect(user: %i[full_name email_address phone bio])
  end
end
