# A review of a property, written by a seeker after a visit. Reviews are public.
class ReviewPolicy < BasePolicy
  def index? = true
  def show?  = true

  # Only after their own completed visit
  def create?
    visit = record.visit
    signed_in? && visit.present? && visit.completed? && visit.application&.user_id == user.id
  end

  def update?  = author?
  # The author, or a moderator (any review)
  def destroy? = author? || moderator?

  private

  def author?
    signed_in? && record.visit&.application&.user_id == user.id
  end

  class Scope < BasePolicy::Scope
    def resolve = scope.all
  end
end
