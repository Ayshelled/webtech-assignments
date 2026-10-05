class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:neighborhood, :user, :listings)
                          .joins(:neighborhood)
                          .order("neighborhoods.name", :street_address)
  end

  def show
    @property = Property.includes(:neighborhood, :user, :amenities).find(params[:id])
    @amenities, @shared_spaces = @property.amenities.sort_by(&:name).partition(&:amenity?)
    @listings = @property.listings.includes(:listing_photos, property: :neighborhood).newest_first
    @reviews  = @property.reviews.includes(visit: { application: :user }).newest_first
  end
end
