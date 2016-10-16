# frozen_string_literal: true
class AddIndexOnTitleToPosts < ActiveRecord::Migration[5.0]
  def change
    add_index :posts, :title
  end
end
