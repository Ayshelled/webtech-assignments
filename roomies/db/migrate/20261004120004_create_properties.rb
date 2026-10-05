class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.references :user,         null: false, foreign_key: true
      t.references :neighborhood, null: false, foreign_key: true
      t.string  :street_address,  null: false, limit: 200
      t.enum    :property_type, enum_type: :property_type, null: false
      t.integer :bedrooms_count,  null: false, default: 1
      t.integer :bathrooms_count, null: false, default: 1

      t.timestamps

      t.check_constraint "bedrooms_count >= 1",  name: "properties_bedrooms_count_positive"
      t.check_constraint "bathrooms_count >= 1", name: "properties_bathrooms_count_positive"
    end
  end
end
