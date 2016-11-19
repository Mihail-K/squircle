# frozen_string_literal: true
class AddDisplayNameToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_column :characters, :display_name, :string

    reversible do |dir|
      dir.up do
        execute(<<-SQL.squish)
          UPDATE
            characters
          SET
            display_name = users.display_name
          FROM
            users
          WHERE
            users.id = characters.user_id
        SQL
      end
    end
  end
end
