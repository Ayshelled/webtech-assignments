# A room a seeker saved for later. Private to that seeker.
class SavedListingPolicy < BasePolicy
  def index?   = signed_in?
  def show?    = owner?
  def create?  = signed_in?
  def destroy? = owner?

  private

  def owner?
    signed_in? && record.user_id == user.id
  end

  class Scope < BasePolicy::Scope
    def resolve
      return scope.none unless user

      scope.where(user_id: user.id)
    end
  end
end
