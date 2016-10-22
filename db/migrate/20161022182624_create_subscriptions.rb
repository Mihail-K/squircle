# frozen_string_literal: true
class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, foreign_key: true, index: true, null: false
      t.belongs_to :conversation, foreign_key: true, index: true, null: false
      t.boolean    :deleted, null: false, default: false
      t.datetime   :deleted_at
      t.belongs_to :deleted_by, foreign_key: { to_table: :users }, index: true

      t.index %i(user_id conversation_id), unique: true
      t.timestamps null: false
    end
  end
end
