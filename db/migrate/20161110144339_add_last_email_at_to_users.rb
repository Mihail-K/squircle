# frozen_string_literal: true
class AddLastEmailAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_email_at, :datetime, index: true
  end
end
