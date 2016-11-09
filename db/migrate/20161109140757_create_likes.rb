# frozen_string_literal: true
class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.belongs_to :likeable, polymorphic: true, index: true, null: false
      t.belongs_to :user, foreign_key: true, index: true, null: false

      t.index %i(likeable_id likeable_type user_id), unique: true

      t.timestamps null: false
    end
  end
end
