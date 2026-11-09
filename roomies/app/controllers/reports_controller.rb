# Reports about listings. Any member or moderator reports a room that isn't theirs
# from the listing page; moderators see every report and resolve it (ReportPolicy).
class ReportsController < ApplicationController
  before_action :set_report, only: %i[dismiss uphold]

  # The moderators' queue, filtered by status (pending by default)
  def index
    authorize Report
    @status = params[:status].presence_in(Report.statuses.keys) || "pending"
    reports = policy_scope(Report)
    @status_counts = reports.group(:status).count
    @reports = reports.where(status: @status)
                      .includes(:user, listing: { property: %i[neighborhood user] })
                      .order(created_at: :desc)
  end

  def create
    @listing = Listing.find(params.expect(:listing_id))
    @report = @listing.reports.new(report_params)
    @report.user = current_user
    authorize @report

    if @report.save
      redirect_to listing_path(@listing), notice: "Thanks. A moderator will review your report.", status: :see_other
    else
      redirect_to listing_path(@listing), alert: "Couldn't send the report: #{@report.errors.full_messages.to_sentence}.",
                                          status: :see_other
    end
  end

  # Nothing wrong with the listing
  def dismiss
    @report.update!(status: :dismissed)
    redirect_to reports_path, notice: "The report about #{@report.listing.title} was dismissed.", status: :see_other
  end

  # The report is right: the listing is withdrawn from the search (if it is still open)
  def uphold
    listing = @report.listing
    Report.transaction do
      @report.update!(status: :actioned)
      listing.withdraw! if listing.can_change_to?(:withdrawn)
    end
    redirect_to reports_path, notice: "The report was upheld and #{listing.title} is #{listing.reload.status}.",
                              status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    redirect_to reports_path, alert: "Couldn't resolve the report: #{e.record.errors.full_messages.to_sentence}.",
                              status: :see_other
  end

  private

  def set_report
    @report = Report.find(params.expect(:id))
    authorize @report
  end

  def report_params
    params.expect(report: %i[reason details])
  end
end
