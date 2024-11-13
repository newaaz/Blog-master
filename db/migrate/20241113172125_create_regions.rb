class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions do |t|
      t.string :name, null: false
      t.references :federal_district, null: false, foreign_key: true

      t.timestamps
    end

    add_index :regions, :name, unique: true
  end
end
