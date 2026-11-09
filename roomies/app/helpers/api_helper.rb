# Helpers for the JSON views of the public API (app/views/api)
module ApiHelper
  # Absolute URL of a listing photo: the resized variant of an uploaded file
  # (served through the Active Storage proxy), or the external URL of a seed photo
  def api_photo_url(photo, variant)
    photo.image.attached? ? rails_representation_url(photo.image.variant(variant)) : photo.image_url
  end
end
