# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :login,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Rememberable
      t.datetime :remember_created_at

      t.string :fio, null: false, default: ""

      t.boolean :admin, null: false, default: false

      t.timestamps null: false
    end

    add_index :users, :login, unique: true
  end
end
