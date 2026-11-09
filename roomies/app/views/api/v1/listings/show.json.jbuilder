json.data do
  json.partial! "api/v1/listings/listing", listing: @listing
  json.description @listing.description.to_plain_text
  json.house_rules @listing.house_rules.to_plain_text
  json.photos @listing.listing_photos do |photo|
    json.url api_photo_url(photo, :large)
    json.alt photo.alt_text
    json.caption photo.caption
  end
end
