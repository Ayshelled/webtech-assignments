class AmenitiesController < ApplicationController
  before_action :set_amenity, only: %i[edit update destroy]

  def index
    @amenities, @shared_spaces = Amenity.alphabetical.to_a.partition(&:amenity?)
    @property_counts = PropertyAmenity.group(:amenity_id).count
  end

  def new
    @amenity = Amenity.new
  end

  def create
    @amenity = Amenity.new(amenity_params)

    if @amenity.save
      redirect_to amenities_path, notice: "#{@amenity.name} was added to the catalog."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @amenity.update(amenity_params)
      redirect_to amenities_path, notice: "#{@amenity.name} was updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  # Removing an amenity also removes it from every property that had it
  def destroy
    @amenity.destroy
    redirect_to amenities_path, notice: "#{@amenity.name} was removed from the catalog.", status: :see_other
  end

  private

  def set_amenity
    @amenity = Amenity.find(params.expect(:id))
  end

  def amenity_params
    params.expect(amenity: %i[name category])
  end
end
