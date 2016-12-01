# frozen_string_literal: true
class CreatePasswordResets < ActiveRecord::Migration[5.0]
  def change
    create_table :password_resets, id: false do |t|
      t.uuid       :token, index: { unique: true }, null: false
      t.belongs_to :user, foreign_key: true, index: true
      t.string     :status, null: false, default: 'open'
      t.string     :email, null: false

      t.timestamps null: false
    end
  end
end
