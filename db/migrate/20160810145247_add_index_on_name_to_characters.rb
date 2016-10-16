# frozen_string_literal: true
class AddIndexOnNameToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_index :characters, :name
  end
end
