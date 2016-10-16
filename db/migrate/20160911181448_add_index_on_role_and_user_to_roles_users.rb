# frozen_string_literal: true
class AddIndexOnRoleAndUserToRolesUsers < ActiveRecord::Migration[5.0]
  def change
    add_index :roles_users, %i(role_id user_id), unique: true
  end
end
