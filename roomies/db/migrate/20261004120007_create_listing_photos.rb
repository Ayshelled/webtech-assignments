class CreateListingPhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true, index: false
      t.string  :caption,  limit: 150
      t.string  :alt_text, limit: 255
      t.integer :position, null: false, default: 0

      t.timestamps

      t.check_constraint "position >= 0", name: "listing_photos_position_not_negative"
    end

    add_index :listing_photos, %i[listing_id position]
  end
end
