class ConversationSerializer < ActiveModel::Serializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :section_id
  attribute :locked_by_id, if: :can_view_locking_user?
  attribute :deleted_by_id, if: :can_view_deleted?

  attribute :title
  attribute :views_count
  attribute :posts_count
  attribute :created_at
  attribute :updated_at
  attribute :last_active_at
  attribute :participated, if: :include_participation?

  attribute :deleted
  attribute :locked
  attribute :locked_on

  belongs_to :author, serializer: UserSerializer
  belongs_to :locked_by, serializer: UserSerializer, if: :can_view_locking_user?
  belongs_to :section
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted?

  has_one :first_post, serializer: PostSerializer, if: :include_first_post?
  has_one :last_post, serializer: PostSerializer, if: :include_last_post?

  def can_view_locking_user?
    object.locked_by_id == current_user.try(:id) ||
    current_user.try(:allowed_to?, :lock_conversations)
  end

  def can_view_deleted?
    current_user.try(:allowed_to?, :view_deleted_conversations)
  end

  def include_participation?
    instance_options[:participated].is_a?(Hash)
  end

  def include_first_post?
    instance_options[:first_posts].is_a?(Hash)
  end

  def include_last_post?
    instance_options[:last_posts].is_a?(Hash)
  end

  def participated
    instance_options[:participated][object.id].present? &&
    instance_options[:participated][object.id] > 0
  end

  def first_post
    instance_options[:first_posts][object.id]
  end

  def last_post
    instance_options[:last_posts][object.id]
  end
end
