class AddDisplayNameToLikes < ActiveRecord::Migration[5.0]
  def up
    add_column :likes, :display_name, :string

    execute(<<-SQL.squish)
      UPDATE
        likes
      SET
        display_name = users.display_name
      FROM
        users
      WHERE
        users.id = likes.user_id
    SQL

    change_column_null :likes, :display_name, false
  end

  def down
    remove_column :likes, :display_name
  end
end
