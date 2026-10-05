class Application < ApplicationRecord
  belongs_to :listing
  belongs_to :user # the seeker
  has_many :visits, dependent: :destroy
  has_many :reviews, through: :visits

  # Lifecycle: pending -> shortlisted -> accepted / rejected; withdrawn from pending or shortlisted.
  enum :status, {
    pending: "pending", shortlisted: "shortlisted", accepted: "accepted",
    rejected: "rejected", withdrawn: "withdrawn"
  }, validate: true

  # Still waiting for the host's final decision
  scope :pending_answer, -> { where(status: %w[pending shortlisted]) }
  scope :newest_first,   -> { order(created_at: :desc) }

  validates :message, presence: true
  validates :desired_move_in_date, presence: true
  validates :intended_stay_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :user_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }
  validate :listing_must_be_published, on: :create
  validate :seeker_cannot_be_the_host, on: :create

  private

  def listing_must_be_published
    return if listing.nil? || listing.published?

    errors.add(:listing, "is not open for applications")
  end

  def seeker_cannot_be_the_host
    return if listing.nil? || user_id.nil?

    errors.add(:user, "can't apply to their own listing") if listing.property.user_id == user_id
  end
end
