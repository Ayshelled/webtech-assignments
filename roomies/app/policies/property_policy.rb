# A place a host owns. Anyone sees the properties; any member registers one
# (becoming its host); the host or a moderator edits or deletes it.
class PropertyPolicy < BasePolicy
  def index? = true
  def show?  = true

  def create?  = signed_in?
  def update?  = host? || moderator?
  def destroy? = host? || moderator?

  # Adding a room to the property
  def add_listing? = host?

  private

  def host?
    signed_in? && record.user_id == user.id
  end

  class Scope < BasePolicy::Scope
    def resolve = scope.all
  end
end
