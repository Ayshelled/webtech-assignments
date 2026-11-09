json.data @neighborhoods do |neighborhood|
  json.extract! neighborhood, :id, :name, :city
  json.published_listings_count @published_counts.fetch(neighborhood.id, 0)
end
json.meta do
  json.total_count @neighborhoods.size
end
