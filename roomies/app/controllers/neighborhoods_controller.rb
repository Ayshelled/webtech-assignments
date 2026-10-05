class NeighborhoodsController < ApplicationController
  def index
    @neighborhoods = Neighborhood.alphabetical
    # { neighborhood_id => number of published listings }, in a single query
    @published_counts = Listing.published.joins(:property).group("properties.neighborhood_id").count
    @property_counts  = Property.group(:neighborhood_id).count
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @listings = Listing.published.in_neighborhood(@neighborhood.id)
                       .includes(:listing_photos, property: :neighborhood)
                       .newest_first
                       .load
    @properties = @neighborhood.properties.includes(:listings).order(:street_address).load
  end
end
