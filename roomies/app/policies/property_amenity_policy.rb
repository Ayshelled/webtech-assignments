# An amenity ticked on a property (the join row). Public, and changed from the
# property form by whoever may edit the property.
class PropertyAmenityPolicy < BasePolicy
  def show?    = true
  def create?  = property_policy.update?
  def update?  = property_policy.update?
  def destroy? = property_policy.update?

  private

  def property_policy = PropertyPolicy.new(user, record.property)

  class Scope < BasePolicy::Scope
    def resolve = scope.all
  end
end
