class ConversationSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :locked_by_id, if: :can_view_locking_user?

  attribute :title
  attribute :views_count
  attribute :posts_count do
    # Unless the viewer is an admin, show only visible post count.
    current_user.try(:admin?) ? object.posts_count : object.visible_posts_count
  end
  attribute :created_at
  attribute :updated_at
  attribute :participated, if: :include_participation? do
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

  def include_participation?
    false # TODO : Set as a controller parameter.
  end
end
