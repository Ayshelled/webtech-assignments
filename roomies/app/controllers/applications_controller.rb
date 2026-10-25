class ApplicationsController < ApplicationController
  include ListingPage
  include ApplicationPage

  before_action :require_acting_user, only: %i[create withdraw]
  def index
    @status = params[:status].presence_in(Application.statuses.keys)
    @status_counts = Application.group(:status).count

    @applications = Application.includes(:user, listing: { property: :neighborhood }).newest_first
    @applications = @applications.where(status: @status) if @status
    @applications.load
  end

  def show
    prepare_application_page(params.expect(:id))
  end

  # A seeker applies from the listing page. If something is wrong, the listing
  # page is rendered again with the errors inside the apply form.
  def create
    @listing = Listing.find(params.expect(:listing_id))
    @application = @listing.applications.new(application_params)
    @application.user = current_user

    if @application.save
      redirect_to listing_path(@listing), notice: "Your application was sent to the host."
    else
      prepare_listing_page(@listing.id)
      render "listings/show", status: :unprocessable_content
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

  private

  def application_params
    params.expect(application: %i[message desired_move_in_date intended_stay_months])
  end
end
