# frozen_string_literal: true
class RemoveDeletedAndDeletedAtAndDeletedByIdFromSubscriptions < ActiveRecord::Migration[5.0]
  def change
    remove_column :subscriptions, :deleted, :boolean, null: false, default: false
    remove_column :subscriptions, :deleted_at, :datetime
    remove_column :subscriptions, :deleted_by_id, :integer, index: true
  end
end
