json.data @amenities do |amenity|
  json.extract! amenity, :id, :name, :category
end
json.meta do
  json.total_count @amenities.size
end
