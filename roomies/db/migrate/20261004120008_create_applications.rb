class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true, index: false
      t.references :user,    null: false, foreign_key: true # the seeker
      t.text    :message,              null: false
      t.date    :desired_move_in_date, null: false
      t.integer :intended_stay_months, null: false
      t.enum    :status, enum_type: :application_status, null: false, default: "pending"

      t.timestamps

      t.check_constraint "intended_stay_months >= 1", name: "applications_intended_stay_positive"
    end

    # A seeker cannot apply twice to the same listing
    add_index :applications, %i[listing_id user_id], unique: true
    add_index :applications, :status
  end
end
