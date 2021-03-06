# frozen_string_literal: true
class AddDeletedByAndDeletedAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :deleted_by, foreign_key: { to_table: :users }, index: true, references: :users
    add_column :users, :deleted_at, :timestamp
  end
end
