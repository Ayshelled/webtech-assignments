# A room offered by a host. Anyone browses the published ones; a draft is seen
# only by its host and by moderators. The host manages the listing; a
# moderator can edit, withdraw or delete any of them.
class ListingPolicy < BasePolicy
  def index? = true

  def show?
    !record.draft? || host? || moderator?
  end

  # A listing is created inside a property: only the property's host adds rooms to it
  def create? = host?

  def update?  = host? || moderator?
  def destroy? = host? || moderator?

  # Lifecycle. Publishing and marking as rented are the host's decisions; a
  # moderator can also take a room off the search by withdrawing it.
  def publish?     = host?
  def mark_rented? = host?
  def withdraw?    = host? || moderator?

  # The applications received by this room
  def see_applications? = host? || moderator?

  # Any member can apply, except to their own room (and only while it is published,
  # which the Application model checks)
  def apply? = signed_in? && !host?

  # Any member or moderator can report a room that isn't theirs
  def report? = signed_in? && !host?

  private

  def host?
    signed_in? && record.property&.user_id == user.id
  end

  # Visitors: what is not a draft. Members: that, plus their own drafts. Moderators: everything.
  class Scope < BasePolicy::Scope
    def resolve
      return scope.all if moderator?
      return scope.where.not(status: :draft) unless user

      scope.where.not(status: :draft)
           .or(scope.where(property_id: Property.where(user_id: user.id).select(:id)))
    end
  end
end
