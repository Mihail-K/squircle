# frozen_string_literal: true
class AddAvatarToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_column :characters, :avatar, :string
  end
end
