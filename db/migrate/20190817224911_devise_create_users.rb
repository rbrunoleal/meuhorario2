# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username,  null: false, default: ""
      t.integer :rule, default: 0
      t.boolean :enable, default: false

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Lockable
      t.datetime :locked_at

      t.timestamps null: false
    end
    add_index :users, :username,   unique: true
  end
end
