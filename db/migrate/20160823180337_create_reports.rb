# frozen_string_literal: true
class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.references :reportable, index: true, polymorphic: true, null: false
      t.string     :status, null: false, index: true, default: 'open'
      t.text       :description
      t.references :creator, foreign_key: { to_table: :users }, null: false
      t.boolean    :deleted, null: false, default: false, index: true
      t.timestamps null: false
    end
  end
end
