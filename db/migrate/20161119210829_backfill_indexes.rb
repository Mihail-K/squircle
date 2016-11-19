# frozen_string_literal: true
class BackfillIndexes < ActiveRecord::Migration[5.0]
  def up
    [Character, Conversation, Post, User].each do |model|
      model.not_deleted.find_each(&:create_index)
    end
  end

  def down
    Index.delete_all
  end
end
