class BanSerializer < ActiveModel::Serializer
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

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer, if: :can_view_ban_creator?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted_bans?

  def can_view_ban_creator?
    current_user.try(:can?, :view_ban_creator)
  end

  def can_view_deleted_bans?
    current_user.try(:can?, :view_deleted_bans)
  end
end
