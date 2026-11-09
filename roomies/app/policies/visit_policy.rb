# A visit arranged on an application. Only the two people of the application
# take part: the host of the room and the seeker who applied.
class VisitPolicy < BasePolicy
  # Propose or cancel a visit: the host of the listing, or the applicant
  def create? = host? || applicant?
  def cancel? = host? || applicant?

  # The seeker confirms the date the host proposed
  def confirm? = applicant?

  # The host reschedules it and marks it as completed after it happened
  def update?   = host?
  def complete? = host?

  private

  def application = record.application

  def applicant?
    signed_in? && application&.user_id == user.id
  end

  def host?
    signed_in? && application&.listing&.property&.user_id == user.id
  end

  class Scope < BasePolicy::Scope
    def resolve
      return scope.none unless user
      return scope.all if moderator?

      scope.where(application_id: ApplicationPolicy::Scope.new(user, Application).resolve.select(:id))
    end
  end
end
