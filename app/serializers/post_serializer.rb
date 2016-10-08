class PostSerializer < ApplicationSerializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :editor_id
  attribute :character_id
  attribute :conversation_id
  attribute :deleted_by_id, if: :can_view_deleted?

  attribute :title
  attribute :body
  attribute :formatted_body
  attribute :deleted
  attribute :created_at
  attribute :updated_at

  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :author, serializer: UserSerializer
  belongs_to :editor, serializer: UserSerializer
  belongs_to :character
  belongs_to :conversation
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted?

  def can_view_deleted?
    current_user.try(:allowed_to?, :view_deleted_posts)
  end
end
