# frozen_string_literal: true
class CreateConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :conversations do |t|
      t.string     :title, null: false
      t.integer    :posts_count, null: false, default: 0
      t.boolean    :deleted, null: false, default: false
      t.references :author, foreign_key: { to_table: :users }, index: true, null: false
      t.timestamps null: false
    end
  end
end
