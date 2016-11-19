# frozen_string_literal: true
class CreateIndices < ActiveRecord::Migration[5.0]
  def change
    create_table :indices do |t|
      t.belongs_to :indexable, null: false, polymorphic: true, index: { unique: true }
      t.string     :primary, null: false, array: true, index: true
      t.text       :secondary, array: true, index: true
      t.text       :tertiary, array: true, index: true
      t.integer    :version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
