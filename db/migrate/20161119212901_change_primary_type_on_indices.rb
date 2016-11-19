# frozen_string_literal: true
class ChangePrimaryTypeOnIndices < ActiveRecord::Migration[5.0]
  def up
    change_column :indices, :primary, :text, array: true, null: false
  end

  def down
    change_column :indices, :primary, :string, array: true, null: false
  end
end
