class CreateSections < ActiveRecord::Migration[5.0]
  def change
    create_table :sections do |t|
      t.string     :title, null: false, index: true
      t.text       :description
      t.string     :logo
      t.integer    :conversations_count, null: false, default: 0
      t.boolean    :deleted, null: false, default: false
      t.references :creator, foreign_key: true, index: true, references: :users, null: false
      t.timestamps null: false
    end
  end
end
