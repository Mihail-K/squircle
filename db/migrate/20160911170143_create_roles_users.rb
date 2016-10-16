# frozen_string_literal: true
class CreateRolesUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :roles_users do |t|
      t.references :role, foreign_key: true, index: true, null: false
      t.references :user, foreign_key: true, index: true, null: false
      t.timestamps null: false
    end
  end
end
