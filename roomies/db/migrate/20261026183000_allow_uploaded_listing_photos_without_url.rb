# Photos uploaded through Active Storage don't have a URL: image_url is only
# kept for the photos that still point to an external image
class AllowUploadedListingPhotosWithoutUrl < ActiveRecord::Migration[8.1]
  def change
    change_column_null :listing_photos, :image_url, true
  end
end
