class AddDeletedByAndDeletedAtToConversations < ActiveRecord::Migration[5.0]
  def change
    add_reference :conversations, :deleted_by, foreign_key: { to_table: :users }, index: true, references: :users
    add_column :conversations, :deleted_at, :timestamp
  end
end
