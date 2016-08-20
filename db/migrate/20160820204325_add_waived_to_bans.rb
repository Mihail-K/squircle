class AddWaivedToBans < ActiveRecord::Migration[5.0]
  def change
    add_column :bans, :waived, :boolean, null: false, default: false
  end
end
