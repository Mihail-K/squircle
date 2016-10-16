# frozen_string_literal: true
class AddViewsCountToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :views_count, :integer, null: false, default: 0
  end
end
