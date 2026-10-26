# "providencia" and "Providencia" are the same neighborhood, and "wi-fi" and
# "Wi-Fi" the same amenity: the unique indexes now compare in lowercase.
class MakeCatalogNamesUniqueIgnoringCase < ActiveRecord::Migration[8.1]
  def change
    remove_index :neighborhoods, %i[name city], unique: true
    add_index :neighborhoods, "lower(name), lower(city)", unique: true,
              name: "index_neighborhoods_on_lower_name_and_lower_city"

    remove_index :amenities, :name, unique: true
    add_index :amenities, "lower(name)", unique: true, name: "index_amenities_on_lower_name"
  end
end
