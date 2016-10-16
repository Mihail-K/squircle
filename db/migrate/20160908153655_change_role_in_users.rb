# frozen_string_literal: true
class ChangeRoleInUsers < ActiveRecord::Migration[5.0]
  def up
    add_reference :users, :role, foreign_key: true, index: true

    execute(<<-SQL.squish).each do |roles|
      SELECT
        id, name
      FROM
        roles
    SQL
      execute sanitize <<-SQL.squish, roles[0], roles[1]
        UPDATE
          users
        SET
          role_id = ?
        WHERE
          role = ?
      SQL
    end

    remove_column :users, :role
  end

  def down
    add_column :users, :role, :string, index: true, null: false, default: 'user'

    execute(<<-SQL.squish).each do |roles|
      SELECT
        id, name
      FROM
        roles
    SQL
      execute sanitize <<-SQL.squish, roles[1], roles[0]
        UPDATE
          users
        SET
          role = ?
        WHERE
          role_id = ?
      SQL
    end

    remove_reference :users, :role
  end

private

  def sanitize(*args)
    ActiveRecord::Base.send :sanitize_sql_array, args
  end
end
