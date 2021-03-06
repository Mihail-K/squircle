# frozen_string_literal: true
class AddDeletedByAndDeletedAtToSections < ActiveRecord::Migration[5.0]
  def change
    add_reference :sections, :deleted_by, foreign_key: { to_table: :users }, index: true, references: :users
    add_column :sections, :deleted_at, :timestamp
  end
end
