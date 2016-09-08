class AddDeletedByAndDeletedAtToSections < ActiveRecord::Migration[5.0]
  def change
    add_reference :sections, :deleted_by, foreign_key: true, index: true, references: :users
    add_column :sections, :deleted_at, :timestamp
  end
end
