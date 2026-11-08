class PagesController < ApplicationController
  # Public part of Roomies: visitors can browse without an account
  allow_unauthenticated_access

  def home
    @neighborhoods = Neighborhood.alphabetical
    @featured_listings = Listing.published
                                .includes({ listing_photos: ListingPhoto::WITH_IMAGE }, property: :neighborhood)
                                .newest_first
                                .limit(3)
  end
end
