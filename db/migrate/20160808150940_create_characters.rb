# frozen_string_literal: true
class CreateCharacters < ActiveRecord::Migration[5.0]
  def change
    create_table :characters do |t|
      t.string     :name, null: false
      t.string     :title
      t.string     :description
      t.references :user, foreign_key: true, index: true
      t.integer    :creator_id, index: true, null: false
      t.timestamps null: false
    end

    add_foreign_key :characters, :users, column: :creator_id
  end
end
