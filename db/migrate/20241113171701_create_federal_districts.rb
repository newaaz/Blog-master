class CreateFederalDistricts < ActiveRecord::Migration[7.0]
  def change
    create_table :federal_districts do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :federal_districts, :name, unique: true
  end
end
