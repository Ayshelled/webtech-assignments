# GET /api/v1/listings      the published rooms, filtered and paginated
# GET /api/v1/listings/:id  one published room
#
# Filters (all optional, combinable): neighborhood_id, amenity_id, max_rent,
# available_by (YYYY-MM-DD). Pagination: page (from 1), per_page (1-50, default 12).
# Order: sort = newest (default), rent_asc or rent_desc.
# Unlike the HTML search, a malformed value is not ignored: the answer is
# 400 Bad Request with the parameter that failed.
module Api
  module V1
    class ListingsController < BaseController
      DEFAULT_PER_PAGE = 12
      MAX_PER_PAGE = 50
      SORTS = {
        "newest"    => { created_at: :desc },
        "rent_asc"  => { monthly_rent: :asc, created_at: :desc },
        "rent_desc" => { monthly_rent: :desc, created_at: :desc }
      }.freeze

      def index
        filters, errors = parse_filters
        return render_error(:bad_request, "Invalid query parameters", errors) if errors.any?

        listings = public_listings
        listings = listings.in_neighborhood(filters[:neighborhood_id]) if filters[:neighborhood_id]
        listings = listings.with_amenity(filters[:amenity_id])         if filters[:amenity_id]
        listings = listings.under_rent(filters[:max_rent])             if filters[:max_rent]
        listings = listings.available_by(filters[:available_by])       if filters[:available_by]

        @total_count = listings.count
        @page = filters[:page]
        @per_page = filters[:per_page]
        @total_pages = (@total_count / @per_page.to_f).ceil
        @filters = filters.slice(:neighborhood_id, :amenity_id, :max_rent, :available_by, :sort).compact
        @listings = listings.reorder(SORTS.fetch(filters[:sort]))
                            .limit(@per_page).offset((@page - 1) * @per_page)
                            .includes(:rich_text_description, { listing_photos: ListingPhoto::WITH_IMAGE },
                                      property: %i[neighborhood amenities])
      end

      def show
        @listing = public_listings.includes(:rich_text_description, :rich_text_house_rules,
                                            { listing_photos: ListingPhoto::WITH_IMAGE },
                                            property: %i[neighborhood amenities])
                                  .find(params.expect(:id))
      end

      private

      # Only published rooms: what ListingPolicy::Scope shows a visitor, minus the
      # rooms that no longer take applications
      def public_listings
        policy_scope(Listing).published
      end

      def parse_filters
        errors = {}
        integer = lambda do |name, min: 1, max: nil|
          raw = params[name]
          next nil if raw.blank?

          value = Integer(raw.to_s, 10, exception: false)
          if value.nil? || value < min || (max && value > max)
            errors[name] = max ? "must be a whole number between #{min} and #{max}" : "must be a whole number greater than or equal to #{min}"
            next nil
          end
          value
        end

        filters = {
          neighborhood_id: integer.call(:neighborhood_id),
          amenity_id:      integer.call(:amenity_id),
          max_rent:        integer.call(:max_rent),
          page:            integer.call(:page) || 1,
          per_page:        integer.call(:per_page, max: MAX_PER_PAGE) || DEFAULT_PER_PAGE
        }

        if params[:available_by].present?
          begin
            filters[:available_by] = Date.iso8601(params[:available_by].to_s)
          rescue Date::Error
            errors[:available_by] = "must be a date in the format YYYY-MM-DD"
          end
        end

        sort = params[:sort].presence || "newest"
        if SORTS.key?(sort)
          filters[:sort] = sort
        else
          errors[:sort] = "must be one of: #{SORTS.keys.join(", ")}"
          filters[:sort] = "newest"
        end

        [ filters, errors ]
      end
    end
  end
end
