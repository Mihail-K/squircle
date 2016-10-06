class AddLockedAndLockedOnAndLockedByToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :locked, :boolean, null: false, default: false
    add_column :conversations, :locked_on, :datetime
    add_reference :conversations, :locked_by, foreign_key: { to_table: :users }, index: true, references: :users, on_delete: :nullify
  end
end
