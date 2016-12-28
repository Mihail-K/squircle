# frozen_string_literal: true
class CreateVisits < ActiveRecord::Migration[5.0]
  def change
    create_table :visits, id: false do |t|
      t.uuid       :id, index: { unique: true }, primary_key: true, null: false, default: 'uuid_generate_v4()'
      t.references :user, foreign_key: true, index: true, on_delete: :nullify
      t.inet       :ip
      t.inet       :remote_ip
      t.string     :user_agent

      t.timestamps null: false
    end
  end
end
