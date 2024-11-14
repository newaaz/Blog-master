class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
