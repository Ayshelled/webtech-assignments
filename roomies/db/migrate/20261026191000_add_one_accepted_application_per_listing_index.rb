# A listing has at most one accepted application. The model validates it; this
# partial unique index guarantees it even if two hosts' requests race.
class AddOneAcceptedApplicationPerListingIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :applications, :listing_id, unique: true, where: "status = 'accepted'",
                                          name: "index_applications_one_accepted_per_listing"
  end
end
