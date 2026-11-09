class ListingsController < ApplicationController
  # Public part of Roomies: visitors can browse without an account
  allow_unauthenticated_access only: %i[index show]

  include ListingPage

  before_action :set_property, only: %i[new create]
  before_action :set_listing, only: %i[edit update destroy publish withdraw mark_rented]
  # Every action asks ListingPolicy: the host manages the room, a moderator can edit,
  # withdraw or delete any of them, and a draft is seen only by them
  before_action :authorize_listing, only: %i[edit update destroy publish withdraw mark_rented]
  RENT_OPTIONS = [ 300_000, 400_000, 500_000, 600_000 ].freeze

  # Only published listings are open for applications, so they are the only ones listed.
  # The search form filters them with the model's named scopes.
  def index
    authorize Listing
    @neighborhoods = Neighborhood.alphabetical
    @amenities     = Amenity.alphabetical
    @filters       = search_filters

    @listings = policy_scope(Listing).published.includes({ listing_photos: ListingPhoto::WITH_IMAGE }, property: :neighborhood).newest_first
    @listings = @listings.in_neighborhood(@filters[:neighborhood_id]) if @filters[:neighborhood_id]
    @listings = @listings.under_rent(@filters[:max_rent])             if @filters[:max_rent]
    @listings = @listings.available_by(@filters[:available_by])       if @filters[:available_by]
    @listings = @listings.with_amenity(@filters[:amenity_id])         if @filters[:amenity_id]
    @listings.load # one query; size/any? in the view reuse the loaded records
  end

  # A draft is visible only to its host and to moderators
  def show
    prepare_listing_page(params.expect(:id))
    authorize @listing
  end

  # A listing is always created inside a property, and starts as a draft
  def new
    @listing = @property.listings.new
    authorize @listing
  end

  def create
    @listing = @property.listings.new(listing_params)
    authorize @listing

    if @listing.save
      redirect_to @listing, notice: "Your room was saved as a draft."
    else
      render_invalid :new, @listing
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "The listing was updated."
    else
      render_invalid :edit, @listing
    end
  end

  # Also removes its applications, with their visits and reviews
  def destroy
    @listing.destroy
    redirect_to property_path(@listing.property), notice: "#{@listing.title} was deleted.", status: :see_other
  end

  # Lifecycle actions of the host. The model rejects a change its state doesn't allow.
  def publish
    change_status(:publish!, "#{@listing.title} is published: seekers can find it and apply.")
  end

  def withdraw
    change_status(:withdraw!, "#{@listing.title} was withdrawn and no longer takes applications.")
  end

  def mark_rented
    change_status(:mark_rented!, "#{@listing.title} is marked as rented. Welcome home to your new housemate!")
  end

  private

  def change_status(action, notice)
    @listing.public_send(action)
    redirect_to @listing, notice: notice, status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @listing, alert: "Couldn't change the listing: #{e.record.errors.full_messages.to_sentence}.",
                          status: :see_other
  end

  # publish -> publish?, mark_rented -> mark_rented?, and so on
  def authorize_listing
    authorize @listing
  end

  def set_property
    @property = Property.find(params.expect(:property_id))
  end

  def set_listing
    @listing = Listing.find(params.expect(:id))
    @property = @listing.property
  end

  # The status is not here: a listing is created as a draft, and the lifecycle
  # actions (publish, withdraw, mark as rented) change it
  # new_photos are the files uploaded from the form; remove_photo_ids the photos ticked for removal
  def listing_params
    params.expect(listing: [ :title, :monthly_rent, :deposit, :available_from, :minimum_stay_months,
                             :furnished, :private_bathroom, :description, :house_rules,
                             new_photos: [], remove_photo_ids: [] ])
  end

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
