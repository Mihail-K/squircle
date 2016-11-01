# frozen_string_literal: true
class RenameLockedOnToLockedAtInConversations < ActiveRecord::Migration[5.0]
  def change
    rename_column :conversations, :locked_on, :locked_at
  end
end
