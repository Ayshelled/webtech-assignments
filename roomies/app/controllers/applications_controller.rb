class ApplicationsController < ApplicationController
  include ListingPage
  include ApplicationPage

  before_action :require_acting_user, only: %i[create withdraw shortlist reject accept]
  before_action :set_received_application, only: %i[shortlist reject accept]

  # The acting user's inbox: the applications received for their rooms (as host), or
  # the ones they sent (as seeker), filtered by status
  def index
    @box = params[:box] == "sent" ? "sent" : "received"
    @status = params[:status].presence_in(Application.statuses.keys)
    return unless current_user

    applications = inbox_scope
    @status_counts = applications.group(:status).count
    @applications = applications.includes(:user, listing: { property: :neighborhood }).newest_first
    @applications = @applications.where(status: @status) if @status
    @applications.load
  end

  def show
    prepare_application_page(params.expect(:id))
  end

  # A seeker applies from the listing page, inside its "application_box" Turbo Frame:
  # the response is just that frame, with the confirmation or the form with its errors.
  # Without Turbo, it falls back to a redirect or to the whole listing page.
  def create
    @listing = Listing.find(params.expect(:listing_id))
    @application = @listing.applications.new(application_params)
    @application.user = current_user

    if @application.save
      notice = "Your application was sent to the host."
      if turbo_frame_request?
        # Only the apply block changes: the form is replaced by the confirmation and the state
        @my_application, @notice = @application, notice
        render :apply_frame
      else
        redirect_to listing_path(@listing), notice: notice
      end
    elsif turbo_frame_request?
      render :apply_frame, status: :unprocessable_content # the form again, with the errors next to each field
    else
      prepare_listing_page(@listing.id)
      render_invalid "listings/show", @application
    end
  end

  # Only its author can withdraw an application
  def withdraw
    @application = current_user.applications.find(params.expect(:id))

    if @application.update(status: :withdrawn)
      redirect_back fallback_location: application_path(@application), notice: "Your application was withdrawn."
    else
      redirect_back fallback_location: application_path(@application),
                    alert: @application.errors.full_messages.to_sentence
    end
  end

  # The host's answers. From the inbox they come back as a Turbo Stream that updates
  # the affected rows and the counts without reloading the page; from the application
  # page, as a redirect back to it.
  def shortlist
    answer(:shortlist!, "#{@application.user.full_name} was shortlisted. You can now propose a visit.")
  end

  def reject
    answer(:reject!, "#{@application.user.full_name}'s application was rejected.")
  end

  def accept
    answer(:accept!, "You accepted #{@application.user.full_name}. #{@application.listing.title} is now reserved " \
                     "and every other pending or shortlisted application to it was rejected.")
  end

  private

  def inbox_scope
    @box == "sent" ? current_user.applications : Application.received_by(current_user)
  end

  # Only the host of the room can answer: anyone else gets a 404
  def set_received_application
    @application = Application.received_by(current_user).includes(:user, :listing).find(params.expect(:id))
  end

  def answer(decision, notice)
    result = @application.public_send(decision)
    # accept! also returns the applications it rejected: their rows change too
    @changed = [ @application, *(result if result.is_a?(Array)) ]
    respond_to_answer(notice: notice)
  rescue ActiveRecord::RecordInvalid => e
    message = e.record.errors.full_messages.to_sentence
    @application.reload
    @changed = [ @application ]
    respond_to_answer(alert: "Couldn't answer the application: #{message}.")
  end

  def respond_to_answer(message)
    if params[:inbox].present? && request.format.turbo_stream?
      message.each { |type, text| flash.now[type] = text }
      @box = "received"
      @status = params[:status].presence_in(Application.statuses.keys)
      @status_counts = Application.received_by(current_user).group(:status).count
      render :answer, formats: :turbo_stream
    else
      target = params[:inbox].present? ? applications_path(status: params[:status]) : application_path(@application)
      redirect_to target, status: :see_other, **message
    end
  end

  def application_params
    params.expect(application: %i[message desired_move_in_date intended_stay_months])
  end
end
