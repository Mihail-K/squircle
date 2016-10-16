# frozen_string_literal: true
class AddPostableToPosts < ActiveRecord::Migration[5.0]
  def change
    add_reference :posts, :postable, polymorphic: true, index: true
  end
end
