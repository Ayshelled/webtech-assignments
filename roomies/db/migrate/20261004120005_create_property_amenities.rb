class CreatePropertyAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :property_amenities do |t|
      # The composite unique index below already covers lookups by property_id
      t.references :property, null: false, foreign_key: true, index: false
      t.references :amenity,  null: false, foreign_key: true

      t.timestamps
    end

    add_index :property_amenities, %i[property_id amenity_id], unique: true
  end
end
