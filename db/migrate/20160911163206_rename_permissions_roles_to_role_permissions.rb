class RenamePermissionsRolesToRolePermissions < ActiveRecord::Migration[5.0]
  def change
    rename_table :permissions_roles, :role_permissions
  end
end
