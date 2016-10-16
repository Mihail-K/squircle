# frozen_string_literal: true
class AddImpliedByToPermissions < ActiveRecord::Migration[5.0]
  def change
    add_reference :permissions, :implied_by, foreign_key: { to_table: :permissions }, index: true
  end
end
