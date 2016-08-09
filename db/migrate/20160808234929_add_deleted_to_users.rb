class AddDeletedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deleted, :false, null: false, default: false, index: true
  end
end
