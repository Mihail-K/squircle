# frozen_string_literal: true
class AddTitleToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :title, :string

    return if reverting?

    execute <<-SQL.squish
      UPDATE
        conversations
      SET
        title = (
          SELECT
            title
          FROM
            posts
          WHERE
            posts.postable_id = conversations.id
          AND
            posts.postable_type = 'Conversation'
          ORDER BY
            posts.created_at ASC
          LIMIT 1
        )
    SQL

    change_column :conversations, :title, :string, null: false
  end
end
