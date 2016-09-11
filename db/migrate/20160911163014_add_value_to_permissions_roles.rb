class AddValueToPermissionsRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :permissions_roles, :value, :string, null: false, index: true, default: 'allow'
  end
end
