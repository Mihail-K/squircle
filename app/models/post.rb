# == Schema Information
#
# Table name: posts
#
#  id              :integer          not null, primary key
#  title           :string
#  body            :text             not null
#  author_id       :integer          not null
#  editor_id       :integer
#  character_id    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted         :boolean          default(FALSE), not null
#  conversation_id :integer          not null
#  formatted_body  :text
#
# Indexes
#
#  index_posts_on_author_id                          (author_id)
#  index_posts_on_character_id                       (character_id)
#  index_posts_on_conversation_id                    (conversation_id)
#  index_posts_on_editor_id                          (editor_id)
#  index_posts_on_postable_type_and_conversation_id  (conversation_id)
#  index_posts_on_title                              (title)
#

class Post < ActiveRecord::Base
  include Formattable

  belongs_to :author, class_name: 'User', counter_cache: :posts_count, inverse_of: :posts
  belongs_to :editor, class_name: 'User'
  belongs_to :character, counter_cache: :posts_count, inverse_of: :posts

  belongs_to :conversation, counter_cache: :posts_count, inverse_of: :posts

  has_one :section, through: :conversation

  delegate :locked?, to: :conversation, allow_nil: true

  validates :author, presence: true
  validates :conversation, presence: true
  validates :body, presence: true, length: { in: 10 .. 10_000, if: :body? }

  formattable :body

  after_create :update_visible_posts_count
  after_update :update_visible_posts_count, if: :deleted_changed?
  after_destroy :update_visible_posts_count

  after_create :update_conversation_activity
  after_update :update_conversation_activity, if: :deleted_changed?
  after_destroy :update_conversation_activity

  scope :first_posts, -> {
    where id: Post.group(Post.arel_table[:conversation_id])
                  .having(
                    Post.arel_table[:created_at]
                        .eq(Post.arel_table[:created_at].minimum)
                        .and(
                          Post.arel_table[:id]
                              .eq(Post.arel_table[:id].minimum)
                        )
                  )
  }

  scope :last_posts, -> {
    where id: Post.group(Post.arel_table[:conversation_id])
                  .having(
                    Post.arel_table[:created_at]
                        .eq(Post.arel_table[:created_at].maximum)
                        .and(
                          Post.arel_table[:id]
                              .eq(Post.arel_table[:id].maximum)
                        )
                  )
  }

  scope :visible, -> {
    where(deleted: false).joins(:conversation)
                         .merge(Conversation.visible)
  }

  def editable_by?(user)
    return true if user.try(:admin?)
    author_id == user.try(:id) && !user.try(:banned?)
  end

private

  def update_visible_posts_count
    author.update_columns visible_posts_count: author.posts.visible.count
    conversation.update_columns visible_posts_count: conversation.posts.visible.count
    section.update_columns posts_count: section.posts.count,
                           visible_posts_count: section.posts.visible.count if section.present?
  end

  def update_conversation_activity
    last_activity = conversation.posts.visible.maximum(:updated_at)
    conversation.update_columns(last_active_at: last_activity)
  end
end
