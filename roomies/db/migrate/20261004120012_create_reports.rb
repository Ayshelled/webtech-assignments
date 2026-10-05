class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :listing, null: false, foreign_key: true, index: false
      t.references :user,    null: false, foreign_key: true # who reports
      t.enum :reason, enum_type: :report_reason, null: false
      t.text :details
      t.enum :status, enum_type: :report_status, null: false, default: "pending"

      t.timestamps
    end

    add_index :reports, %i[listing_id user_id], unique: true
    add_index :reports, :status
  end
end
