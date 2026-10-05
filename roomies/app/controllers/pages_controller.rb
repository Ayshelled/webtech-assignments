class PagesController < ApplicationController
  def home
    @neighborhoods = Neighborhood.alphabetical
    @featured_listings = Listing.published
                                .includes(:listing_photos, property: :neighborhood)
                                .newest_first
                                .limit(3)
  end
end
