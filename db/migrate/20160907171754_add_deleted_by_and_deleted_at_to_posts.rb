class AddDeletedByAndDeletedAtToPosts < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :deleted_by, foreign_key: true, index: true, references: :users
    add_column :posts, :deleted_at, :timestamp
  end
end
