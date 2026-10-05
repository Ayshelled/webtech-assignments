class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address,   null: false, limit: 255
      t.string :password_digest, null: false
      t.string :full_name,       null: false, limit: 120
      t.string :phone,           limit: 30
      t.enum   :role, enum_type: :user_role, null: false, default: "member"

      t.timestamps
    end

    add_index :users, :email_address, unique: true
  end
end
