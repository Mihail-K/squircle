# frozen_string_literal: true
class AddRequestIpToPasswordResets < ActiveRecord::Migration[5.0]
  def change
    add_column :password_resets, :request_ip, :inet
  end
end
