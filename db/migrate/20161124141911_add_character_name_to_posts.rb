# frozen_string_literal: true
class AddCharacterNameToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :character_name, :string

    reversible do |dir|
      dir.up do
        execute(<<-SQL.squish)
          UPDATE
            posts
          SET
            character_name = characters.name
          FROM
            characters
          WHERE
            characters.id = posts.character_id
        SQL
      end
    end
  end
end
