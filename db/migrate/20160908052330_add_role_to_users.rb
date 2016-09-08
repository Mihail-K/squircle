class AddRoleToUsers < ActiveRecord::Migration[5.0]
  def self.up
    add_column :users, :role, :string, null: false, default: 'user'

    execute sanitize <<-SQL.squish, true
      UPDATE
        users
      SET
        role = 'admin'
      WHERE
        admin = ?
    SQL

    remove_column :users, :admin
  end

  def self.down
    add_column :users, :admin, :boolean, null: false, default: true

    execute sanitize <<-SQL.squish, true
      UPDATE
        users
      SET
        admin = ?
      WHERE
        role = 'admin'
    SQL

    remove_column :users, :role
  end

private

  def sanitize(*args)
    ActiveRecord::Base.send :sanitize_sql_array, args
  end
end
