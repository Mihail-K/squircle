# frozen_string_literal: true
class AddDeletedByAndDeletedAtToRolePermissions < ActiveRecord::Migration[5.0]
  def change
    add_column :role_permissions, :deleted, :boolean, null: false, default: false, index: true
    add_reference :role_permissions, :deleted_by, foreign_key: { to_table: :users }, index: true, references: :users
    add_column :role_permissions, :deleted_at, :timestamp
  end
end
