class BanSerializer < ActiveModel::Serializer
  attribute :id
  attribute :user_id
  attribute :creator_id, if: :can_view_banning_user?

  attribute :reason
  attribute :expires_at
  attribute :permanent
  attribute :expired
  attribute :created_at
  attribute :updated_at

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer, if: :can_view_banning_user?

  def can_view_banning_user?
    current_user.try(:admin?)
  end
end
