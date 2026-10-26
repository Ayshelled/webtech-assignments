class ReviewsController < ApplicationController
  include PropertyPage

  before_action :require_acting_user
  before_action :set_review, only: %i[edit update destroy]

  # Written from the property page, about one of the acting user's completed visits
  def create
    @property = Property.find(params.expect(:property_id))
    @review = Review.new(review_params.except(:visit_id))
    # Only a visit of the acting user to this property can be reviewed: anything else
    # leaves the review without a visit, and its validations reject it
    @review.visit = reviewable_visits(@property).find_by(id: review_params[:visit_id])

    if @review.save
      redirect_to property_path(@property), notice: "Thanks! Your review was published."
    else
      prepare_property_page(@property.id)
      render_invalid "properties/show", @review
    end
  end

  def edit
  end

  def update
    if @review.update(review_params.except(:visit_id))
      redirect_to property_path(@property), notice: "Your review was updated."
    else
      render_invalid :edit, @review
    end
  end

  def destroy
    @review.destroy
    redirect_to property_path(@property), notice: "Your review was deleted.", status: :see_other
  end

  private

  # Only the author of a review can change it
  def set_review
    @review = Review.joins(visit: :application)
                    .where(applications: { user_id: current_user.id })
                    .find(params.expect(:id))
    @property = @review.visit.application.listing.property
  end

  def review_params
    params.expect(review: %i[visit_id rating comment])
  end
end
