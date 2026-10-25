# Loads everything the application page shows. Used by applications#show, and by
# visits#create when it renders the page again to show the visit form errors.
module ApplicationPage
  extend ActiveSupport::Concern

  private

  def prepare_application_page(application_id)
    @application = Application.includes(:user, listing: [ :listing_photos, { property: %i[neighborhood user] } ])
                              .find(application_id)
    @visits = @application.visits.includes(:review).order(:scheduled_at)
    @visit ||= Visit.new
  end
end
