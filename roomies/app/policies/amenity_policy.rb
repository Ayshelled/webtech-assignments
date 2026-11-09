# The catalog of amenities and shared spaces. Visitors and members see them on
# the property pages; the catalog page and its changes belong to moderators.
class AmenityPolicy < BasePolicy
  def index?   = moderator?
  def show?    = true

  def create?  = moderator?
  def update?  = moderator?
  def destroy? = moderator?

  class Scope < BasePolicy::Scope
    def resolve = scope.all
  end
end
