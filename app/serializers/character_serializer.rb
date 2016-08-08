class CharacterSerializer < ActiveModel::Serializer
  attribute :id
  attribute :user_id
  attribute :creator_id

  attribute :name
  attribute :title
  attribute :description
  attribute :created_at

  belongs_to :user
  belongs_to :creator, serializer: UserSerializer
end
