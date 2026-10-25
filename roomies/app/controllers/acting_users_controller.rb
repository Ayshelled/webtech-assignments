# Switches the user you are acting as (the select in the navigation bar)
class ActingUsersController < ApplicationController
  def update
    user = User.find_by(id: params[:user_id])

    if user
      session[:acting_user_id] = user.id
      redirect_back fallback_location: root_path, notice: "You are now acting as #{user.full_name}."
    else
      session.delete(:acting_user_id)
      redirect_back fallback_location: root_path, notice: "You are now browsing as a visitor."
    end
  end
end
