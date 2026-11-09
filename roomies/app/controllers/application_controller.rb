class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Hiding a button is only a courtesy: every action asks its policy. This check
  # fails loudly in development and tests if an action forgets to call authorize.
  # Controllers that need no policy (sign in, sign up, password reset, the
  # landing page) skip it.
  after_action :verify_authorized

  # An unauthorized attempt lands on a page that explains what happened
  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  helper_method :current_user

  private

  # The signed-in user, or nil for a visitor. Pundit uses this method too.
  def current_user
    resume_session&.user
  end

  # The 403 page. The explanation comes from config/locales/en.yml
  # (pundit.<policy>.<query>), with a general one as fallback.
  def forbidden(exception)
    policy_name = exception.policy.class.to_s.underscore
    @reason = t("pundit.#{policy_name}.#{exception.query}", default: :"pundit.default")
    @signed_in = current_user.present?

    respond_to do |format|
      format.json { render json: { error: { status: 403, message: @reason } }, status: :forbidden }
      format.any  { render "errors/forbidden", status: :forbidden, formats: :html, layout: "application" }
    end
  end

  # A form that couldn't be saved: render it again with each error next to its
  # field, and report the failure in a flash alert
  def render_invalid(template, record)
    flash.now[:alert] = "Couldn't save the #{record.model_name.human.downcase}: #{record.errors.full_messages.to_sentence}."
    render template, status: :unprocessable_content
  end
end
