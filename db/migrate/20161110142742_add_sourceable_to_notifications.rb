# frozen_string_literal: true
class AddSourceableToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_reference :notifications, :sourceable, polymorphic: true, index: true
  end
end
