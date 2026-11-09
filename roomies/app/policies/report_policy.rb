# A member's report about a listing. Any member or moderator reports a room that
# isn't theirs; only moderators see the reports and resolve them.
class ReportPolicy < BasePolicy
  def index? = moderator?
  def show?  = moderator?

  def create?
    signed_in? && record.listing&.property&.user_id != user.id
  end

  # Dismiss it, or uphold it (the listing is withdrawn)
  def resolve? = moderator?
  def dismiss? = resolve?
  def uphold?  = resolve?

  class Scope < BasePolicy::Scope
    def resolve
      return scope.all if moderator?
      return scope.none unless user

      scope.where(user_id: user.id)
    end
  end
end
