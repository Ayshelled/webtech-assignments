# GET /api/v1/neighborhoods  the catalog, with how many published rooms each one has
module Api
  module V1
    class NeighborhoodsController < BaseController
      def index
        @neighborhoods = policy_scope(Neighborhood).alphabetical
        @published_counts = Listing.published.joins(:property).group("properties.neighborhood_id").count
      end
    end
  end
end
