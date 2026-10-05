class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      # unique: one review per visit
      t.references :visit, null: false, foreign_key: true, index: { unique: true }
      t.integer :rating,  null: false
      t.text    :comment, null: false

      t.timestamps

      t.check_constraint "rating BETWEEN 1 AND 5", name: "reviews_rating_between_1_and_5"
    end
  end
end
