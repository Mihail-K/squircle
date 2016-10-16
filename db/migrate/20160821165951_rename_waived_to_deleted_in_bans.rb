# frozen_string_literal: true
class RenameWaivedToDeletedInBans < ActiveRecord::Migration[5.0]
  def change
    rename_column :bans, :waived, :deleted
  end
end
