class AddPostsCountAndVisiblePostsCountToSection < ActiveRecord::Migration[5.0]
  def change
    add_column :sections, :posts_count, :integer, null: false, default: 0
    add_column :sections, :visible_posts_count, :integer, null: false, default: 0

    execute(<<-SQL.squish).each do |result|
      SELECT
        sections.id,
        COUNT(posts.id)
      FROM
        sections
      JOIN
        conversations ON conversations.section_id = sections.id
      JOIN
        posts ON posts.conversation_id = conversations.id
      GROUP BY
        sections.id
    SQL
      execute(sanitize(<<-SQL.squish, result[1], result[0]))
        UPDATE
          sections
        SET
          posts_count = ?
        WHERE
          id = ?
      SQL
    end

    execute(sanitize(<<-SQL.squish, false, false)).each do |result|
      SELECT
        sections.id,
        COUNT(posts.id)
      FROM
        sections
      JOIN
        conversations ON conversations.section_id = sections.id
      JOIN
        posts ON posts.conversation_id = conversations.id
      WHERE
        posts.deleted = ?
      AND
        conversations.deleted = ?
      GROUP BY
        sections.id
    SQL
      execute(sanitize(<<-SQL.squish, result[1], result[0]))
        UPDATE
          sections
        SET
          visible_posts_count = ?
        WHERE
          id = ?
      SQL
    end
  end

private

  def sanitize(*args)
    ActiveRecord::Base.send :sanitize_sql_array, args
  end
end
