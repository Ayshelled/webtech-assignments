class AddImageUrlToListingPhotos < ActiveRecord::Migration[8.1]
  def change
    # Photos are referenced by URL; file uploads (Active Storage) are out of scope for a read-only assignment
    add_column :listing_photos, :image_url, :string, limit: 500, null: false
  end
end
