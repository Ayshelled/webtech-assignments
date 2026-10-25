# Loads everything the property page shows. Used by properties#show, and by
# reviews#create when it renders the page again to show the review form errors.
module PropertyPage
  extend ActiveSupport::Concern

  private

  def prepare_property_page(property_id)
    @property = Property.includes(:neighborhood, :user, :amenities).find(property_id)
    @amenities, @shared_spaces = @property.amenities.sort_by(&:name).partition(&:amenity?)
    @listings = @property.listings.includes(:listing_photos, property: :neighborhood).newest_first
    @reviews  = @property.reviews.includes(visit: { application: :user }).newest_first
    @reviewable_visits = reviewable_visits(@property).to_a
    @review ||= Review.new
  end

  # Completed visits of the acting user to this property that don't have a review yet
  def reviewable_visits(property)
    return Visit.none unless current_user

    Visit.completed.where.missing(:review)
         .joins(application: :listing)
         .where(applications: { user_id: current_user.id }, listings: { property_id: property.id })
         .includes(application: :listing)
         .order(scheduled_at: :desc)
  end
end
