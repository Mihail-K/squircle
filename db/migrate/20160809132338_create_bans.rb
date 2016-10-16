# frozen_string_literal: true
class CreateBans < ActiveRecord::Migration[5.0]
  def change
    create_table :bans do |t|
      t.string     :reason, null: false
      t.datetime   :expires_at
      t.references :user, foreign_key: true, index: true, null: false, on_delete: :cascade
      t.integer    :creator_id, null: false, index: true
      t.timestamps null: false
    end
    add_foreign_key :bans, :users, column: :creator_id
  end
end
