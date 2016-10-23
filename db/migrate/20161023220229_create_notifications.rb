# frozen_string_literal: true
class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.belongs_to :user, foreign_key: true, index: true, null: false
      t.belongs_to :targetable, index: true, null: false, polymorphic: true
      t.string     :title, null: false
      t.boolean    :read, null: false, default: false, index: true
      t.boolean    :dismissed, null: false, default: false, index: true

      t.index %i(read dismissed)

      t.timestamps null: false
    end
  end
end
