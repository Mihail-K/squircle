class AddPostsCountToUsersAndCharacters < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :posts_count, :integer, null: false, default: 0
    add_column :characters, :posts_count, :integer, null: false, default: 0

    execute <<-SQL.squish unless reverting?
      UPDATE
        users
      SET
        posts_count = (
          SELECT
            COUNT(*)
          FROM
            posts
          WHERE
            poster_id = users.id
        )
    SQL
    execute <<-SQL.squish unless reverting?
      UPDATE
        characters
      SET
        posts_count = (
          SELECT
            COUNT(*)
          FROM
            posts
          WHERE
            character_id = characters.id
          AND
            character_id IS NOT NULL
        )
    SQL
  end
end
