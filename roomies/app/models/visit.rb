class Visit < ApplicationRecord
  belongs_to :application
  has_one :review, dependent: :destroy

  # Lifecycle: proposed -> confirmed / cancelled; confirmed -> completed.
  # A reschedule is a new visit, so the application keeps its history.
  enum :status, {
    proposed: "proposed", confirmed: "confirmed", cancelled: "cancelled", completed: "completed"
  }, validate: true

  scope :upcoming, -> { where(scheduled_at: Time.current..).order(:scheduled_at) }

  # The states each state can move to. Cancelled and completed are final.
  TRANSITIONS = {
    "proposed"  => %w[confirmed cancelled],
    "confirmed" => %w[completed cancelled]
  }.freeze

  validates :scheduled_at, presence: true
  validate :scheduled_after_application_was_created
  # Proposing a visit (it starts as proposed) needs a shortlisted application
  validate :application_must_be_shortlisted, on: :create, if: :proposed?
  # A visit still to happen can't be (re)scheduled in the past
  validate :scheduled_in_the_future, if: -> { will_save_change_to_scheduled_at? && (proposed? || confirmed?) }
  validate :status_change_must_be_allowed, on: :update, if: :will_save_change_to_status?

  private

  def application_must_be_shortlisted
    return if application.nil? || application.shortlisted?

    errors.add(:base, "A visit can only be proposed on a shortlisted application (this one is #{application.status})")
  end

  def scheduled_in_the_future
    return if scheduled_at.blank? || scheduled_at > Time.current

    errors.add(:scheduled_at, "can't be in the past")
  end

  def status_change_must_be_allowed
    from = status_in_database
    return if TRANSITIONS.fetch(from, []).include?(status)

    errors.add(:status, "can't change from #{from} to #{status}")
  end

  def scheduled_after_application_was_created
    return if scheduled_at.blank? || application.nil?

    applied_at = application.created_at || Time.current
    errors.add(:scheduled_at, "must be after the application was sent") if scheduled_at <= applied_at
  end
end
