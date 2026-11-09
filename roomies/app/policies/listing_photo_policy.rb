# A photograph of a listing: seen whenever the listing is, and managed (from the
# listing form) by whoever may edit the listing.
class ListingPhotoPolicy < BasePolicy
  def show?    = listing_policy.show?
  def create?  = listing_policy.update?
  def update?  = listing_policy.update?
  def destroy? = listing_policy.update?

  private

  def listing_policy = ListingPolicy.new(user, record.listing)

  class Scope < BasePolicy::Scope
    def resolve
      scope.where(listing_id: ListingPolicy::Scope.new(user, Listing).resolve.select(:id))
    end
  end
end
