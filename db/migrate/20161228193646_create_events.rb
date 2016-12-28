# frozen_string_literal: true
class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events, id: false do |t|
      t.uuid       :id, null: false, index: { unique: true }, primary_key: true, default: 'uuid_generate_v4()'
      t.belongs_to :user, foreign_key: true
      t.uuid       :visit_id
      t.string     :controller, null: false
      t.string     :method, null: false
      t.string     :action, null: false
      t.integer    :status, null: false
      t.json       :body

      t.timestamps null: false
    end

    add_foreign_key :events, :visits
  end
end
