# frozen_string_literal: true
class AddFormattedBodyToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :formatted_body, :text

    execute('SELECT id, body FROM posts').each do |post|
      body = Formatter.render post[1]
      execute ActiveRecord::Base.send :sanitize_sql_array, [<<-SQL.squish, body, post[0]]
        UPDATE posts SET formatted_body = ? WHERE id = ?
      SQL
    end
  end
end
