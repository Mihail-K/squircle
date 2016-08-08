class PostSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour

  attribute :id
  attribute :poster_id
  attribute :editor_id
  attribute :character_id

  attribute :title
  attribute :body
  attribute :created_at
  attribute :updated_at

  belongs_to :poster, serializer: UserSerializer
  belongs_to :editor, serializer: UserSerializer
  belongs_to :character
end
