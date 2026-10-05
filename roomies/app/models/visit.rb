class Visit < ApplicationRecord
  belongs_to :application
  has_one :review, dependent: :destroy

  # Lifecycle: proposed -> confirmed / cancelled; confirmed -> completed.
  # A reschedule is a new visit, so the application keeps its history.
  enum :status, {
    proposed: "proposed", confirmed: "confirmed", cancelled: "cancelled", completed: "completed"
  }, validate: true

  scope :upcoming, -> { where(scheduled_at: Time.current..).order(:scheduled_at) }

  validates :scheduled_at, presence: true
  validate :scheduled_after_application_was_created

  private

  def scheduled_after_application_was_created
    return if scheduled_at.blank? || application.nil?

    applied_at = application.created_at || Time.current
    errors.add(:scheduled_at, "must be after the application was sent") if scheduled_at <= applied_at
  end
end
