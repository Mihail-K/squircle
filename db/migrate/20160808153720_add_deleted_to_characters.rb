class AddDeletedToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_column :characters, :deleted, :boolean, null: false, default: false, index: true
  end
end
