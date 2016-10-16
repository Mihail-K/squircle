# frozen_string_literal: true
class ChangeDateOfBirthToDateInUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :date_of_birth, :date, null: false
  end
end
