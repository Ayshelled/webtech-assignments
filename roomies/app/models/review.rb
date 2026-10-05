class Review < ApplicationRecord
  belongs_to :visit
  has_one :application, through: :visit

  scope :newest_first, -> { order(created_at: :desc) }

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :comment, presence: true
  validates :visit_id, uniqueness: true
  validate :visit_must_be_completed

  private

  def visit_must_be_completed
    return if visit.nil? || visit.completed?

    errors.add(:visit, "must be completed before it can be reviewed")
  end
end
