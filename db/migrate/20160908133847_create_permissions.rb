class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.string     :name, null: false, index: { unique: true }
      t.text       :description
      t.boolean    :deleted, null: false, index: true, default: false
      t.references :deleted_by, foreign_key: true, index: true, references: :users
      t.timestamp  :deleted_at
      t.timestamps null: false
    end
  end
end
