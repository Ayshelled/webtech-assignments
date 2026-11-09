# The base class of every policy. Pundit's generator calls it ApplicationPolicy,
# but in Roomies that is the policy of the Application model (a seeker's
# application to a room), so the base class is BasePolicy instead.
#
# user is the signed-in User, or nil for a visitor: every rule must answer for nil.
# Everything is forbidden unless a policy allows it.
class BasePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  private

  def signed_in? = user.present?
  def moderator? = user&.moderator? || false

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope

    def moderator? = user&.moderator? || false
  end
end
