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
#  deleted_by_id   :integer
#  deleted_at      :datetime
#
# Indexes
#
#  index_posts_on_author_id                          (author_id)
#  index_posts_on_character_id                       (character_id)
#  index_posts_on_conversation_id                    (conversation_id)
#  index_posts_on_deleted_by_id                      (deleted_by_id)
#  index_posts_on_editor_id                          (editor_id)
#  index_posts_on_postable_type_and_conversation_id  (conversation_id)
#  index_posts_on_title                              (title)
#

class Post < ApplicationRecord
  include Formattable

  belongs_to :author, class_name: 'User', inverse_of: :posts
  belongs_to :editor, class_name: 'User'
  belongs_to :character, counter_cache: :posts_count, inverse_of: :posts

  belongs_to :conversation, inverse_of: :posts

  has_one :section, through: :conversation

  delegate :locked?, to: :conversation, allow_nil: true

  validates :author, presence: true
  validates :conversation, presence: true
  validates :body, presence: true, length: { in: 10 .. 10_000, if: :body? }

  formattable :body

  before_commit :update_author_posts_count
  before_commit :update_conversation_posts_count
  before_commit :update_section_posts_count
  before_commit :update_conversation_activity

  if Rails.env.development? || Rails.env.test?
    scope :first_posts, -> {
      group(:conversation_id).having(
                               Post.arel_table[:created_at]
                                   .eq(Post.arel_table[:created_at].minimum)
                             )
                             .having(
                               Post.arel_table[:id]
                                   .eq(Post.arel_table[:id].minimum)
                             )
    }

    scope :last_posts, -> {
      group(:conversation_id).having(
                               Post.arel_table[:created_at]
                                   .eq(Post.arel_table[:created_at].maximum)
                             )
                             .having(
                               Post.arel_table[:id]
                                   .eq(Post.arel_table[:id].maximum)
                             )
    }
  else
    scope :first_posts, -> {
      select(<<-SQL.squish)
        first_value("posts"."id")
      OVER
        (PARTITION BY "posts"."conversation_id" ORDER BY "posts"."created_at" ASC)
      SQL
    }

    scope :last_posts, -> {
      select(<<-SQL.squish)
        first_value("posts"."id")
      OVER
        (PARTITION BY "posts"."conversation_id" ORDER BY "posts"."created_at" DESC)
      SQL
    }
  end

  scope :flood, -> {
    where Post.arel_table[:created_at].gteq(20.seconds.ago)
  }

  scope :visible, -> {
    not_deleted.joins(:conversation)
               .merge(Conversation.visible)
  }

  def editable_by?(user)
    return true if user.try(:allowed_to?, :update_posts)
    author_id == user.try(:id) && user.try(:allowed_to?, :update_owned_posts)
  end

private

  def update_author_posts_count
    author.update_columns(posts_count: author.posts.visible.count)
  end

  def update_conversation_posts_count
    conversation.update_columns(posts_count: conversation.posts.visible.count)
  end

  def update_section_posts_count
    section.update_columns(posts_count: section.posts.visible.count) if section.present?
  end

  def update_conversation_activity
    last_activity = conversation.posts.visible.maximum(:updated_at)
    conversation.update_columns(last_active_at: last_activity)
  end
end
