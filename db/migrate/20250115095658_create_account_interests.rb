class CreateAccountInterests < ActiveRecord::Migration[7.0]
  def change
    create_table :account_interests do |t|
      t.references :account, null: false, foreign_key: true
      t.references :interest, null: false, foreign_key: true

      t.timestamps
    end
  end
end
