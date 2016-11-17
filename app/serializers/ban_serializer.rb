# frozen_string_literal: true
class BanSerializer < ApplicationSerializer
  attribute :id
  attribute :user_id
  attribute :creator_id, if: :allowed_to_create_bans?
  attribute :deleted_by_id, if: :allowed_to_view_deleted_bans?

  attribute :reason
  attribute :expires_at
  attribute :permanent
  attribute :expired
  attribute :deleted
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_bans?

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :user
  belongs_to :creator, if: :allowed_to_create_bans?
  belongs_to :deleted_by, if: :allowed_to_view_deleted_bans?
end
