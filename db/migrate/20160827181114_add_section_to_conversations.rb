class AddSectionToConversations < ActiveRecord::Migration[5.0]
  def change
    add_reference :conversations, :section, foreign_key: true, index: true
  end
end
