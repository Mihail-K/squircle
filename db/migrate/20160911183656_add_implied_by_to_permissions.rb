class AddImpliedByToPermissions < ActiveRecord::Migration[5.0]
  def change
    add_reference :permissions, :implied_by, foreign_key: true
  end
end
