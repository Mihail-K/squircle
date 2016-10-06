class AddDeletedByAndDeletedAtToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_reference :characters, :deleted_by, foreign_key: { to_table: :users }, index: true, references: :users
    add_column :characters, :deleted_at, :timestamp
  end
end
