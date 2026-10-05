class ListingsController < ApplicationController
  RENT_OPTIONS = [ 300_000, 400_000, 500_000, 600_000 ].freeze

  # Only published listings are open for applications, so they are the only ones listed.
  # The search form filters them with the model's named scopes.
  def index
    @neighborhoods = Neighborhood.alphabetical
    @amenities     = Amenity.alphabetical
    @filters       = search_filters

    @listings = Listing.published.includes(:listing_photos, property: :neighborhood).newest_first
    @listings = @listings.in_neighborhood(@filters[:neighborhood_id]) if @filters[:neighborhood_id]
    @listings = @listings.under_rent(@filters[:max_rent])             if @filters[:max_rent]
    @listings = @listings.available_by(@filters[:available_by])       if @filters[:available_by]
    @listings = @listings.with_amenity(@filters[:amenity_id])         if @filters[:amenity_id]
    @listings.load # one query; size/any? in the view reuse the loaded records
  end

  def show
    @listing  = Listing.includes(:listing_photos).find(params[:id])
    @property = Property.includes(:neighborhood, :user, :amenities).find(@listing.property_id)
    @amenities, @shared_spaces = @property.amenities.sort_by(&:name).partition(&:amenity?)
    @reviews = @property.reviews.includes(visit: { application: :user }).newest_first
    @other_listings = @property.listings.published.where.not(id: @listing.id)
                               .includes(:listing_photos, property: :neighborhood)
  end

  private

  # Ignores blank or malformed values instead of failing, so a hand-edited URL still renders
  def search_filters
    {
      neighborhood_id: positive_integer(params[:neighborhood_id]),
      amenity_id:      positive_integer(params[:amenity_id]),
      max_rent:        positive_integer(params[:max_rent]),
      available_by:    parse_date(params[:available_by])
    }
  end

  def positive_integer(value)
    number = Integer(value.to_s, 10, exception: false)
    number if number&.positive?
  end

  def parse_date(value)
    Date.iso8601(value.to_s)
  rescue Date::Error
    nil
  end
end
