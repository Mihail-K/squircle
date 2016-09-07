class AddDeletedByAndDeletedAtToBans < ActiveRecord::Migration[5.0]
  def change
    add_reference :bans, :deleted_by, foreign_key: true, index: true, references: :users
    add_column :bans, :deleted_at, :timestamp
  end
end
