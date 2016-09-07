class BanSerializer < ActiveModel::Serializer
  attribute :id
  attribute :user_id
  attribute :creator_id, if: :can_view_banning_user?
  attribute :deleted_by_id, if: :can_view_deleted?

  attribute :reason
  attribute :expires_at
  attribute :permanent
  attribute :expired
  attribute :deleted
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :can_view_deleted?

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer, if: :can_view_banning_user?
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted?

  def can_view_banning_user?
    current_user.try(:admin?)
  end

  def can_view_deleted?
    current_user.try(:admin?)
  end
end
