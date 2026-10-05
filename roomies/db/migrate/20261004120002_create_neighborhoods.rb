class CreateNeighborhoods < ActiveRecord::Migration[8.0]
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false, limit: 100
      t.string :city, null: false, limit: 100

      t.timestamps
    end

    add_index :neighborhoods, %i[name city], unique: true
  end
end
