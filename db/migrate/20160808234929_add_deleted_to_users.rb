# frozen_string_literal: true
class AddDeletedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :deleted, :boolean, null: false, default: false, index: true
  end
end
