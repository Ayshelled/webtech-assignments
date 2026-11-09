# A signed-in browser (the Session model of the authentication generator).
# Signing in and out goes through SessionsController, which needs no policy;
# this keeps a member from ever reaching someone else's sessions.
class SessionPolicy < BasePolicy
  def index?   = signed_in?
  def show?    = owner?
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
