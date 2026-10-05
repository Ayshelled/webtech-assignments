class Report < ApplicationRecord
  belongs_to :listing
  belongs_to :user # who reports

  enum :reason, {
    fraudulent: "fraudulent", misleading: "misleading", offensive: "offensive", other: "other"
  }, validate: true
  enum :status, { pending: "pending", dismissed: "dismissed", actioned: "actioned" }, validate: true

  validates :user_id, uniqueness: { scope: :listing_id, message: "has already reported this listing" }
end
