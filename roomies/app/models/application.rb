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

  # The states each state can move to. Accepted, rejected and withdrawn are final.
  TRANSITIONS = {
    "pending"     => %w[shortlisted accepted rejected withdrawn],
    "shortlisted" => %w[accepted rejected withdrawn]
  }.freeze

  # Still waiting for the host's final decision
  scope :pending_answer, -> { where(status: %w[pending shortlisted]) }
  scope :newest_first,   -> { order(created_at: :desc) }
  # Applications to the rooms of a host: their inbox
  scope :received_by, ->(host) { where(listing_id: Listing.joins(:property).where(properties: { user_id: host.id }).select(:id)) }

  validates :message, presence: true
  validates :desired_move_in_date, presence: true
  validates :intended_stay_months, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :user_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }
  validate :listing_must_be_published, on: :create
  validate :seeker_cannot_be_the_host, on: :create
  validate :status_change_must_be_allowed, on: :update, if: :will_save_change_to_status?
  validate :only_one_accepted_per_listing, if: -> { accepted? && will_save_change_to_status? }

  def awaiting_answer?
    pending? || shortlisted?
  end

  # The host can only answer while the room is still published
  def decidable?
    awaiting_answer? && listing.published?
  end

  def shortlist!
    decide!(:shortlisted)
  end

  def reject!
    decide!(:rejected)
  end

  # Accepting an applicant: this application is accepted, every other pending or
  # shortlisted application to the room is rejected, and the room is reserved.
  # The three changes happen together or not at all: if any of them fails, the
  # transaction rolls back and the database is left as it was.
  # Returns the applications that were rejected automatically.
  def accept!
    transaction do
      # Row locks: another answer to the same room waits until this one finishes,
      # and both records are reloaded so the checks below see their current state
      listing.lock!
      lock!
      decide!(:accepted)

      others = listing.applications.pending_answer.where.not(id: id).to_a
      others.each { |other| other.update!(status: :rejected) }
      listing.update!(status: :reserved)
      others
    end
  end

  private

  # The host's answer: only while the room is published, and only along TRANSITIONS
  def decide!(new_status)
    unless listing.published?
      errors.add(:base, "#{listing.title} is #{listing.status} and no longer takes answers")
      raise ActiveRecord::RecordInvalid, self
    end

    update!(status: new_status)
  end

  def listing_must_be_published
    return if listing.nil? || listing.published?

    errors.add(:listing, "is not open for applications")
  end

  def seeker_cannot_be_the_host
    return if listing.nil? || user_id.nil?

    errors.add(:user, "can't apply to their own listing") if listing.property.user_id == user_id
  end

  def status_change_must_be_allowed
    from = status_in_database
    return if TRANSITIONS.fetch(from, []).include?(status)

    errors.add(:status, "can't change from #{from} to #{status}")
  end

  # The database also enforces it, with a unique index on listing_id where status = 'accepted'
  def only_one_accepted_per_listing
    return unless Application.accepted.where(listing_id: listing_id).where.not(id: id).exists?

    errors.add(:base, "This room already has an accepted application")
  end
end
