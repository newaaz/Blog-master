class CreateAccountSkills < ActiveRecord::Migration[7.0]
  def change
    create_table :account_skills do |t|
      t.references :account, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true

      t.index [:account_id, :skill_id], unique: true

      t.timestamps
    end
  end
end
