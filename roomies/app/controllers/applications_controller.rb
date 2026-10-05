class ApplicationsController < ApplicationController
  def index
    @status = params[:status].presence_in(Application.statuses.keys)
    @status_counts = Application.group(:status).count

    @applications = Application.includes(:user, listing: { property: :neighborhood }).newest_first
    @applications = @applications.where(status: @status) if @status
    @applications.load
  end

  def show
    @application = Application.includes(:user, listing: [ :listing_photos, { property: %i[neighborhood user] } ])
                              .find(params[:id])
    @visits = @application.visits.includes(:review).order(:scheduled_at)
  end
end
