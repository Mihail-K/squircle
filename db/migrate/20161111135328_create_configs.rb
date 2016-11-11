# frozen_string_literal: true
class CreateConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :configs do |t|
      t.string :key, null: false, index: { unique: true }
      t.jsonb  :value, null: false, default: {}

      t.timestamps null: false
    end
  end
end
