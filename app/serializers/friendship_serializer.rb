class FriendshipSerializer < ActiveModel::Serializer
  attribute :id
  attribute :user_id
  attribute :friend_id

  attribute :created_at
  attribute :updated_at

  belongs_to :user
  belongs_to :friend
end
