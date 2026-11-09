class PagesController < ApplicationController
  # Public part of Roomies: visitors can browse without an account
  allow_unauthenticated_access
  # No record to authorize: signing in, signing up and the landing page are open to everyone
  skip_after_action :verify_authorized

  def home
    @neighborhoods = Neighborhood.alphabetical
    @featured_listings = Listing.published
                                .includes({ listing_photos: ListingPhoto::WITH_IMAGE }, property: :neighborhood)
                                .newest_first
                                .limit(3)
  end
end
