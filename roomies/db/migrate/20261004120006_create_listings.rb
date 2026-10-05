class CreateListings < ActiveRecord::Migration[8.0]
  def change
    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true
      t.enum    :status, enum_type: :listing_status, null: false, default: "draft"
      t.decimal :monthly_rent, precision: 10, scale: 2, null: false
      t.decimal :deposit,      precision: 10, scale: 2, null: false, default: 0
      t.date    :available_from,      null: false
      t.integer :minimum_stay_months, null: false, default: 1
      t.boolean :furnished,           null: false, default: false
      t.boolean :private_bathroom,    null: false, default: false
      t.text    :description,         null: false
      t.text    :house_rules

      t.timestamps

      t.check_constraint "monthly_rent > 0",         name: "listings_monthly_rent_positive"
      t.check_constraint "deposit >= 0",             name: "listings_deposit_not_negative"
      t.check_constraint "minimum_stay_months >= 1", name: "listings_minimum_stay_positive"
    end

    add_index :listings, :status
    add_index :listings, :available_from
  end
end
