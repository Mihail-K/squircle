# frozen_string_literal: true
class CreateVisits < ActiveRecord::Migration[5.0]
  def change
    create_table :visits do |t|
      t.uuid       :token, index: { unique: true }, null: false, default: 'uuid_generate_v4()'
      t.references :user, foreign_key: true, index: true, on_delete: :nullify
      t.inet       :ip
      t.string     :user_agent

      t.timestamps null: false
    end
  end
end
