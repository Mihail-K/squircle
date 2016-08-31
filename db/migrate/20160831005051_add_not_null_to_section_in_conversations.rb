class AddNotNullToSectionInConversations < ActiveRecord::Migration[5.0]
  def change
    change_column_null :conversations, :section_id, false
  end
end
