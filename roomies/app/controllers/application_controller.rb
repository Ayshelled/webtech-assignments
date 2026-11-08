class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  private

  # The signed-in user, or nil for a visitor. Pundit uses this method too.
  def current_user
    resume_session&.user
  end

  # A form that couldn't be saved: render it again with each error next to its
  # field, and report the failure in a flash alert
  def render_invalid(template, record)
    flash.now[:alert] = "Couldn't save the #{record.model_name.human.downcase}: #{record.errors.full_messages.to_sentence}."
    render template, status: :unprocessable_content
  end
end
