class NeighborhoodsController < ApplicationController
  before_action :set_neighborhood, only: %i[show edit update destroy]

  def index
    @neighborhoods = Neighborhood.alphabetical
    # { neighborhood_id => number of published listings }, in a single query
    @published_counts = Listing.published.joins(:property).group("properties.neighborhood_id").count
    @property_counts  = Property.group(:neighborhood_id).count
  end

  def show
    @listings = Listing.published.in_neighborhood(@neighborhood.id)
                       .includes(:listing_photos, property: :neighborhood)
                       .newest_first
                       .load
    @properties = @neighborhood.properties.includes(:listings).order(:street_address).load
  end

  def new
    @neighborhood = Neighborhood.new
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)

    if @neighborhood.save
      redirect_to @neighborhood, notice: "#{@neighborhood.name} was added to the catalog."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood, notice: "#{@neighborhood.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # A neighborhood with properties can't be removed (dependent: :restrict_with_error)
  def destroy
    if @neighborhood.destroy
      redirect_to neighborhoods_path, notice: "#{@neighborhood.name} was removed from the catalog.", status: :see_other
    else
      redirect_to @neighborhood, alert: @neighborhood.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params.expect(:id))
  end

  def neighborhood_params
    params.expect(neighborhood: %i[name city])
  end
end
