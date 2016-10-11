class BanSerializer < ApplicationSerializer
  cache expires_in: 6.hours

  attribute :id
  attribute :user_id
  attribute :creator_id, if: :can_view_ban_creator?
  attribute :deleted_by_id, if: :can_view_deleted_bans?

  attribute :reason
  attribute :expires_at
  attribute :permanent
  attribute :expired
  attribute :deleted
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :can_view_deleted_bans?

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer, if: :can_view_ban_creator?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_bans?

  def can_view_ban_creator?
    allowed_to?(:view_ban_creator)
  end

  def can_view_deleted_bans?
    allowed_to?(:view_deleted_bans)
  end
end
