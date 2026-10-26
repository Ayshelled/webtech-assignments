class PropertiesController < ApplicationController
  include PropertyPage

  before_action :require_acting_user, only: %i[new create]
  before_action :set_property, only: %i[edit update destroy]
  before_action :load_form_options, only: %i[new create edit update]

  def index
    @properties = Property.includes(:neighborhood, :user, :listings)
                          .joins(:neighborhood)
                          .order("neighborhoods.name", :street_address)
  end

  def show
    prepare_property_page(params.expect(:id))
  end

  def new
    @property = Property.new
  end

  # The acting user becomes the host of the property
  def create
    @property = current_user.properties.new(property_params)

    if @property.save
      redirect_to @property, notice: "Your property was registered. Now add the rooms you want to publish."
    else
      render_invalid :new, @property
    end
  end

  def edit
  end

  # Assigning amenity_ids rewrites the join table right away, so the update runs
  # in a transaction: if the property is invalid, the amenities are left as they were.
  def update
    saved = Property.transaction do
      @property.update(property_params) || raise(ActiveRecord::Rollback)
    end

    if saved
      redirect_to @property, notice: "The property was updated."
    else
      render_invalid :edit, @property
    end
  end

  # Also removes its listings, with their applications, visits and reviews
  def destroy
    @property.destroy
    redirect_to properties_path, notice: "The property at #{@property.street_address} was deleted.", status: :see_other
  end

  private

  def set_property
    @property = Property.find(params.expect(:id))
  end

  def load_form_options
    @neighborhoods = Neighborhood.alphabetical
    @amenity_options, @shared_space_options = Amenity.alphabetical.to_a.partition(&:amenity?)
  end

  def property_params
    params.expect(property: [ :street_address, :neighborhood_id, :property_type,
                              :bedrooms_count, :bathrooms_count, amenity_ids: [] ])
  end
end
