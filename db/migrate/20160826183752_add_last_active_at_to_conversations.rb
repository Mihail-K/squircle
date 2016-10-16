# frozen_string_literal: true
class AddLastActiveAtToConversations < ActiveRecord::Migration[5.0]
  def change
    add_column :conversations, :last_active_at, :datetime

    execute(sanitize(<<-SQL.squish, false)).each do |result|
      SELECT
        conversations.id,
        MAX(posts.updated_at)
      FROM
        conversations
      JOIN
        posts ON posts.conversation_id = conversations.id
      WHERE
        posts.deleted = ?
      GROUP BY
        conversations.id
    SQL
      execute sanitize <<-SQL.squish, result[1], result[0]
        UPDATE
          conversations
        SET
          last_active_at = ?
        WHERE
          id = ?
      SQL
    end unless reverting?
  end

private

  def sanitize(*args)
    ActiveRecord::Base.send :sanitize_sql_array, args
  end
end
