class VisitsController < ApplicationController
  include ApplicationPage

  before_action :set_visit, except: :create

  # The host proposes a visit from the application page
  def create
    @application = Application.find(params.expect(:application_id))
    @visit = @application.visits.new(visit_params)

    if @visit.save
      redirect_to application_path(@application), notice: "Visit proposed. The seeker can now confirm it."
    else
      prepare_application_page(@application.id)
      render "applications/show", status: :unprocessable_content
    end
  end

  def confirm
    change_status(:confirmed, "Visit confirmed. See you there!")
  end

  def cancel
    change_status(:cancelled, "The visit was cancelled.")
  end

  def complete
    change_status(:completed, "Visit marked as completed. The seeker can now review the property.")
  end

  # Rescheduling keeps the history: the current visit is cancelled and a new one
  # is proposed with the new date. Both happen together or not at all.
  def edit
    @new_visit = Visit.new(scheduled_at: @visit.scheduled_at)
  end

  def update
    @new_visit = Visit.new(visit_params.merge(application: @visit.application))

    Visit.transaction do
      @visit.update!(status: :cancelled)
      @new_visit.save!
    end
    redirect_to application_path(@visit.application), notice: "Visit rescheduled. The seeker can confirm the new date."
  rescue ActiveRecord::RecordInvalid
    @visit.reload
    render :edit, status: :unprocessable_content
  end

  private

  def set_visit
    @visit = Visit.find(params.expect(:id))
  end

  def change_status(status, message)
    if @visit.update(status: status)
      redirect_to application_path(@visit.application), notice: message
    else
      redirect_to application_path(@visit.application), alert: @visit.errors.full_messages.to_sentence
    end
  end

  def visit_params
    params.expect(visit: [ :scheduled_at ])
  end
end
