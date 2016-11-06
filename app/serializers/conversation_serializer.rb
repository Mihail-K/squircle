# frozen_string_literal: true
class ConversationSerializer < ApplicationSerializer
  cache expires_in: 1.hour

  attribute :id
  attribute :author_id
  attribute :section_id
  attribute :locked_by_id, if: :allowed_to_lock_conversations?
  attribute :deleted_by_id, if: :allowed_to_view_deleted_conversations?

  attribute :title
  attribute :views_count
  attribute :posts_count
  attribute :created_at
  attribute :updated_at
  attribute :deleted_at, if: :allowed_to_view_deleted_conversations?
  attribute :last_active_at
  attribute :participated, if: :include_participation?

  attribute :deleted
  attribute :locked
  attribute :locked_at

  attribute :postable do
    allowed_to?(:create_posts) && (!object.locked? || allowed_to?(:lock_conversations))
  end
  attribute :lockable do
    allowed_to?(:lock_conversations)
  end
  attribute :subscribable do
    current_user.present?
  end
  attribute :editable do
    policy.update? || false
  end
  attribute :deletable do
    policy.destroy? || false
  end

  belongs_to :author
  belongs_to :locked_by, if: :allowed_to_lock_conversations?
  belongs_to :section
  belongs_to :deleted_by, if: :allowed_to_view_deleted_conversations?

  has_one :first_post
  has_one :last_post
  has_one :subscription, if: :include_subscription?

  def include_participation?
    instance_options[:participation].is_a?(Hash)
  end

  def participated
    instance_options[:participation][object.id]&.positive? || false
  end

  def include_subscription?
    instance_options[:subscriptions].is_a?(Hash)
  end
  
  def subscription
    instance_options[:subscriptions][object.id]
  end
end
