class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string     :title
      t.text       :body, null: false
      t.references :poster,    foreign_key: true, index: true, null: false, references: :users
      t.references :editor,    foreign_key: true, index: true, references: :users
      t.references :character, foreign_key: true, index: true, references: :characters
      t.timestamps  null: false
    end
  end
end
