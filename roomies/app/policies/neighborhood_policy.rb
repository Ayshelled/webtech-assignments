# The catalog of neighborhoods: public to browse, managed by moderators.
class NeighborhoodPolicy < BasePolicy
  def index? = true
  def show?  = true

  def create?  = moderator?
  def update?  = moderator?
  def destroy? = moderator?

  class Scope < BasePolicy::Scope
    def resolve = scope.all
  end
end
