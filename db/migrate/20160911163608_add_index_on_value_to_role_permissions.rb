# frozen_string_literal: true
class AddIndexOnValueToRolePermissions < ActiveRecord::Migration[5.0]
  def change
    add_index :role_permissions, :value
  end
end
