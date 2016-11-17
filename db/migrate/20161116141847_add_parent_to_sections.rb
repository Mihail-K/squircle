# frozen_string_literal: true
class AddParentToSections < ActiveRecord::Migration[5.0]
  def change
    add_reference :sections, :parent, references: :sections, foreign_key: { to_table: :sections }, index: true
  end
end
