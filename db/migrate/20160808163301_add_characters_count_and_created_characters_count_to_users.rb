class AddCharactersCountAndCreatedCharactersCountToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :characters_count, :integer, null: false, default: 0
    add_column :users, :created_characters_count, :integer, null: false, default: 0
  end
end
