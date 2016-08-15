class PostSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :editor_id
  attribute :character_id
  attribute :conversation_id

  attribute :title
  attribute :body
  attribute :formatted_body
  attribute :editable do
    object.author_id == current_user.try(:id) ||
    current_user.try(:admin?)
  end
  attribute :deleted
  attribute :created_at
  attribute :updated_at

  belongs_to :author, serializer: UserSerializer
  belongs_to :editor, serializer: UserSerializer
  belongs_to :character
  belongs_to :conversation
end
