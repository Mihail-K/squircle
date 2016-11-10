# frozen_string_literal: true
class AddBucketToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :bucket, :string, null: false, default: 'active', index: true
  end
end
