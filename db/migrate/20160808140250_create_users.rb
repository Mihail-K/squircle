# frozen_string_literal: true
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string    :email, null: false
      t.string    :email_token
      t.datetime  :email_confirmed_at
      t.string    :password_digest
      t.string    :display_name
      t.string    :first_name
      t.string    :last_name
      t.datetime  :date_of_birth
      t.timestamps null: false

      t.index     :email, unique: true
      t.index     :email_token, unique: true
      t.index     :display_name, unique: true
    end
  end
end
