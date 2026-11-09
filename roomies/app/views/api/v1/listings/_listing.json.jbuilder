# The public representation of a listing. On purpose it has nothing about people:
# no host or seeker names, emails, phones, applications, nor the street address
# (the host may live there); only the neighborhood.
photo = listing.cover_photo

json.id listing.id
json.title listing.title
json.status listing.status
json.monthly_rent listing.monthly_rent.to_i
json.deposit listing.deposit.to_i
json.currency "CLP"
json.available_from listing.available_from
json.minimum_stay_months listing.minimum_stay_months
json.furnished listing.furnished
json.private_bathroom listing.private_bathroom
json.summary listing.description.to_plain_text.squish.truncate(200)
json.cover_photo(photo ? { url: api_photo_url(photo, :card), alt: photo.alt_text } : nil)
json.neighborhood do
  json.extract! listing.property.neighborhood, :id, :name, :city
end
json.property do
  json.type listing.property.property_type
  json.bedrooms listing.property.bedrooms_count
  json.bathrooms listing.property.bathrooms_count
  json.amenities listing.property.amenities.sort_by(&:name).map(&:name)
end
json.links do
  json.self api_v1_listing_url(listing)
  json.html listing_url(listing)
end
