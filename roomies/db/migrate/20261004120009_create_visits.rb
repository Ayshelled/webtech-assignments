class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :application, null: false, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.enum     :status, enum_type: :visit_status, null: false, default: "proposed"

      t.timestamps
    end
  end
end
