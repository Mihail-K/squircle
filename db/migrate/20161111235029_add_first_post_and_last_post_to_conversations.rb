class AddFirstPostAndLastPostToConversations < ActiveRecord::Migration[5.0]
  def up
    add_reference :conversations, :first_post, index: true
    add_reference :conversations, :last_post, index: true

    add_foreign_key :conversations, :posts, column: :first_post_id, on_delete: :nullify
    add_foreign_key :conversations, :posts, column: :last_post_id, on_delete: :nullify

    execute(<<-SQL.squish)
      UPDATE
        conversations
      SET
        first_post_id = posts.first_post_id,
        last_post_id  = posts.last_post_id
      FROM (
        SELECT
          conversations.id AS conversation_id,
          first_value(posts.id) OVER (PARTITION BY conversations.id ORDER BY posts.created_at ASC) AS first_post_id,
          first_value(posts.id) OVER (PARTITION BY conversations.id ORDER BY posts.created_at DESC) AS last_post_id
        FROM
          conversations
        JOIN
          posts
        ON
          posts.conversation_id = conversations.id
      ) AS posts
      WHERE
        posts.conversation_id = conversations.id
    SQL
  end

  def down
    remove_column :conversations, :first_post_id
    remove_column :conversations, :last_post_id
  end
end
