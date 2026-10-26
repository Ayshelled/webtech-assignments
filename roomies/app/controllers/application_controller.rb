class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  # There are no accounts until Assignment 4: the select in the navigation bar
  # chooses which user you are acting as, and that user authors every action.
  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:acting_user_id])
  end

  # A form that couldn't be saved: render it again with each error next to its
  # field, and report the failure in a flash alert
  def render_invalid(template, record)
    flash.now[:alert] = "Couldn't save the #{record.model_name.human.downcase}: #{record.errors.full_messages.to_sentence}."
    render template, status: :unprocessable_content
  end

  def require_acting_user
    return if current_user

    redirect_back fallback_location: root_path,
                  alert: "Choose who you are acting as in the navigation bar first."
  end
end
