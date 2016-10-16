# frozen_string_literal: true
class ChangeConversationInToNotNullInPosts < ActiveRecord::Migration[5.0]
  def change
    change_column :posts, :conversation_id, :integer, null: false
  end
end
