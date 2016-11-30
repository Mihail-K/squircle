# frozen_string_literal: true
class CreateEmailConfirmations < ActiveRecord::Migration[5.0]
  def change
    create_table :email_confirmations, id: false do |t|
      t.uuid       :token, null: false, index: { unique: true }
      t.belongs_to :user, foreign_key: true, null: false, index: true
      t.string     :status, null: false, index: true, default: 'open'
      t.string     :old_email
      t.string     :new_email, null: false

      t.timestamps null: false
    end
  end
end
