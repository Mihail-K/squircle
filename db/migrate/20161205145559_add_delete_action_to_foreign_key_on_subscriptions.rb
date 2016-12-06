# frozen_string_literal: true
class AddDeleteActionToForeignKeyOnSubscriptions < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :notifications, :users
    add_foreign_key :notifications, :users, on_delete: :cascade
    remove_foreign_key :subscriptions, :users
    add_foreign_key :subscriptions, :users, on_delete: :cascade
  end
end
