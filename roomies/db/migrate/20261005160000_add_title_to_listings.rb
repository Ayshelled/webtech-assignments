class AddTitleToListings < ActiveRecord::Migration[8.1]
  def change
    # A short headline for the listing card ("Sunny room near Metro Tobalaba")
    add_column :listings, :title, :string, limit: 100, null: false
  end
end
