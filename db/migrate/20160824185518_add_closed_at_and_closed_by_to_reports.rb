class AddClosedAtAndClosedByToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :closed_at, :datetime
    add_reference :reports, :closed_by, foreign_key: { to_table: :users }, index: true, references: :users
  end
end
