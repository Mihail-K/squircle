# frozen_string_literal: true
class AddDisplayNameToPosts < ActiveRecord::Migration[5.0]
  def up
    add_column :posts, :display_name, :string

    execute(<<-SQL.squish)
      UPDATE
        posts
      SET
        display_name = users.display_name
      FROM
        users
      WHERE
        users.id = posts.author_id
    SQL

    change_column_null :posts, :display_name, false
  end

  def down
    remove_column :posts, :display_name
  end
end
