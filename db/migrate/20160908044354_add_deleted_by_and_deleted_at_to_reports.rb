class AddDeletedByAndDeletedAtToReports < ActiveRecord::Migration[5.0]
  def change
    add_reference :reports, :deleted_by, foreign_key: true, index: true, references: :users
    add_column :reports, :deleted_at, :timestamp
  end
end
