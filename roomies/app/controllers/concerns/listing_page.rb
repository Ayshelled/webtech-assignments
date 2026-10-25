# Loads everything the listing page shows. Used by listings#show, and by
# applications#create when it renders the page again to show the form errors.
module ListingPage
  extend ActiveSupport::Concern

  private

  def prepare_listing_page(listing_id)
    @listing  = Listing.includes(:listing_photos).find(listing_id)
    @property = Property.includes(:neighborhood, :user, :amenities).find(@listing.property_id)
    @amenities, @shared_spaces = @property.amenities.sort_by(&:name).partition(&:amenity?)
    @reviews = @property.reviews.includes(visit: { application: :user }).newest_first
    @other_listings = @property.listings.published.where.not(id: @listing.id)
                               .includes(:listing_photos, property: :neighborhood)

    # The apply block: the acting user's application to this room, or a new one for the form
    @my_application = current_user && @listing.applications.find_by(user: current_user)
    @application ||= Application.new
  end
end
