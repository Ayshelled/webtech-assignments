# A member's account. Each member sees and edits only their own profile.
class UserPolicy < BasePolicy
  def show?   = me?
  def update? = me?

  private

  def me?
    signed_in? && record.id == user.id
  end

  class Scope < BasePolicy::Scope
    def resolve
      return scope.all if moderator?
      return scope.none unless user

      scope.where(id: user.id)
    end
  end
end
