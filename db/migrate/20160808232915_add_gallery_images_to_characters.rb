# frozen_string_literal: true
class AddGalleryImagesToCharacters < ActiveRecord::Migration[5.0]
  def change
    add_column :characters, :gallery_images, :string
  end
end
