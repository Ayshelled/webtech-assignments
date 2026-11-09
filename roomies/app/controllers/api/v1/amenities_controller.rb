# GET /api/v1/amenities  the catalog of amenities and shared spaces (to filter the listings)
module Api
  module V1
    class AmenitiesController < BaseController
      def index
        @amenities = policy_scope(Amenity).alphabetical
      end
    end
  end
end
