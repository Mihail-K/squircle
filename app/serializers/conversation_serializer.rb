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
  attribute :last_active_at
  attribute :participated, if: :include_participation?

  attribute :locked
  attribute :locked_on

  belongs_to :author, serializer: UserSerializer
  belongs_to :locked_by, serializer: UserSerializer, if: :can_view_locking_user?
  belongs_to :section

  has_one :first_post, serializer: PostSerializer, if: :include_first_post?

  def can_view_locking_user?
    object.locked_by_id == current_user.try(:id) ||
    current_user.try(:admin?)
  end

  def include_participation?
    instance_options[:participated].is_a?(Hash)
  end

  def include_first_post?
    instance_options[:first_posts].is_a?(Hash)
  end

  def participated
    instance_options[:participated][object.id].present? &&
    instance_options[:participated][object.id] > 0
  end

  def first_post
    instance_options[:first_posts][object.id]
  end
end
