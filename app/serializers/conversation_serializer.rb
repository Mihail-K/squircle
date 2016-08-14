class ConversationSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour
  
  attribute :id
  attribute :author_id
  attribute :locked_by_id, if: :can_view_locking_user?

  attribute :title
  attribute :views_count
  attribute :posts_count
  attribute :created_at
  attribute :updated_at
  attribute :participated do
    current_user && object.post_authors.exists?(id: current_user.id)
  end

  attribute :locked
  attribute :locked_on

  belongs_to :author, serializer: UserSerializer
  belongs_to :locked_by, serializer: UserSerializer, if: :can_view_locking_user?

  has_one :first_post, serializer: PostSerializer
  has_one :last_post, serializer: PostSerializer

  def can_view_locking_user?
    object.locked_by_id == current_user.try(:id) ||
    current_user.try(:admin?)
  end
end
