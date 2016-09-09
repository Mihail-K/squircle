class CreatePermissionsRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions_roles do |t|
      t.references :role, foreign_key: true, index: true, null: false
      t.references :permission, foreign_key: true, index: true, null: false
      t.timestamps null: false

      t.index %i(role_id permission_id), unique: true
    end
  end
end
