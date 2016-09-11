class RemoveRoleFromUsers < ActiveRecord::Migration[5.0]
  def self.up
    execute(<<-SQL.squish).each do |result|
      SELECT
        id,
        role_id
      FROM
        users
    SQL
      execute(sanitize(<<-SQL.squish, result[0], result[1], Time.zone.now, Time.zone.now))
        INSERT INTO
          roles_users(user_id, role_id, created_at, updated_at)
        VALUES
          (?, ?, ?, ?)
      SQL
    end

    remove_reference :users, :role, foreign_key: true, index: true, null: false
  end

  def self.down
    add_reference :users, :role, foreign_key: true, index: true

    execute(<<-SQL.squish).each do |result|
      SELECT
        user_id,
        role_id
      FROM
        roles_users
    SQL
      execute(sanitize(<<-SQL.squish, result[1], result[0]))
        UPDATE
          users
        SET
          role_id = ?
        WHERE
          id = ?
      SQL
    end
  end

private

  def self.sanitize(*args)
    ActiveRecord::Base.send :sanitize_sql_array, args
  end
end
