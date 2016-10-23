# frozen_string_literal: true
class NotificationSerializer < ApplicationSerializer
  attribute :id
  attribute :user_id
  attribute :targetable_id
  attribute :targetable_type

  attribute :title
  attribute :read
  attribute :dismissed
  attribute :created_at
  attribute :updated_at

  belongs_to :user
  belongs_to :targetable, polymorphic: true
end
