class CreateAmenities < ActiveRecord::Migration[8.0]
  def change
    create_table :amenities do |t|
      t.string :name, null: false, limit: 60
      t.enum   :category, enum_type: :amenity_category, null: false, default: "amenity"

      t.timestamps
    end

    add_index :amenities, :name, unique: true
  end
end
