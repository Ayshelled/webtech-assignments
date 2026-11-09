# The policy of the Application model: a seeker's application to a room.
# (Not the base class of the policies, which is BasePolicy.)
#
# An application is seen by the seeker who wrote it, by the host of the room and
# by moderators. Only the host answers it; only the seeker withdraws it.
class ApplicationPolicy < BasePolicy
  def index? = signed_in?

  def show? = seeker? || host? || moderator?

  # Any member applies, except to their own room
  def create? = signed_in? && !host?

  def withdraw? = seeker?

  # Shortlist, reject or accept: the host of the room only (not even a moderator)
  def answer?     = host?
  def shortlist?  = answer?
  def reject?     = answer?
  def accept?     = answer?

  private

  def seeker?
    signed_in? && record.user_id == user.id
  end

  def host?
    signed_in? && record.listing&.property&.user_id == user.id
  end

  # The query itself returns only what the user may see: a member gets the
  # applications they sent plus the ones received by their rooms (the inbox);
  # a moderator gets all of them; a visitor none.
  class Scope < BasePolicy::Scope
    def resolve
      return scope.none unless user
      return scope.all if moderator?

      scope.where(user_id: user.id).or(scope.received_by(user))
    end
  end
end
