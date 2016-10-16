# frozen_string_literal: true
class ConversationSerializer < ApplicationSerializer
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

  attribute :postable do
    allowed_to?(:create_posts) && (!object.locked? || allowed_to?(:lock_conversations))
  end
  attribute :lockable do
    allowed_to?(:lock_conversations)
  end
  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :author, serializer: UserSerializer
  belongs_to :locked_by, serializer: UserSerializer, if: :can_view_locking_user?
  belongs_to :section
  belongs_to :deleted_by, serializer: UserSerializer, if: :can_view_deleted?

  belongs_to :first_post, serializer: PostSerializer
  belongs_to :last_post, serializer: PostSerializer

  def can_view_locking_user?
    current_user.try(:allowed_to?, :lock_conversations)
  end

  def can_view_deleted?
    current_user.try(:allowed_to?, :view_deleted_conversations)
  end

  def include_participation?
    instance_options[:participated].is_a?(Hash)
  end

  def participated
    instance_options[:participated][object.id].present? &&
      instance_options[:participated][object.id].positive?
  end
end
