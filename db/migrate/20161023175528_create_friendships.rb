class CreateFriendships < ActiveRecord::Migration[5.0]
  def change
    create_table :friendships do |t|
      t.belongs_to :user, foreign_key: true, null: false, index: true, on_delete: :cascade
      t.belongs_to :friend, foreign_key: { to_table: :users }, null: false, index: true, on_delete: :cascade

      t.index %i(user_id friend_id), unique: true

      t.timestamps null: false
    end
  end
end
