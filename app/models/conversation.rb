# frozen_string_literal: true
# == Schema Information
#
# Table name: conversations
#
#  id             :integer          not null, primary key
#  posts_count    :integer          default(0), not null
#  deleted        :boolean          default(FALSE), not null
#  author_id      :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  views_count    :integer          default(0), not null
#  title          :string           not null
#  locked         :boolean          default(FALSE), not null
#  locked_at      :datetime
#  locked_by_id   :integer
#  last_active_at :datetime
#  section_id     :integer          not null
#  deleted_by_id  :integer
#  deleted_at     :datetime
#  first_post_id  :integer
#  last_post_id   :integer
#
# Indexes
#
#  index_conversations_on_author_id      (author_id)
#  index_conversations_on_deleted_by_id  (deleted_by_id)
#  index_conversations_on_first_post_id  (first_post_id)
#  index_conversations_on_last_post_id   (last_post_id)
#  index_conversations_on_locked_by_id   (locked_by_id)
#  index_conversations_on_section_id     (section_id)
#
# Foreign Keys
#
#  fk_rails_23b24f1951  (locked_by_id => users.id)
#  fk_rails_2f01fbea46  (last_post_id => posts.id) ON DELETE => nullify
#  fk_rails_98fb1708f1  (first_post_id => posts.id) ON DELETE => nullify
#  fk_rails_a10f02b3e3  (deleted_by_id => users.id)
#  fk_rails_add3e5cc0c  (section_id => sections.id)
#  fk_rails_c9ec5eb09c  (author_id => users.id)
#

class Conversation < ApplicationRecord
  include Indexable
  include PostCountable
  include SoftDeletable

  belongs_to :author, class_name: 'User'
  belongs_to :locked_by, class_name: 'User'
  belongs_to :section, inverse_of: :conversations

  has_many :posts, inverse_of: :conversation, dependent: :destroy
  has_many :subscriptions, inverse_of: :conversation, dependent: :destroy

  has_many :post_authors, -> { distinct }, through: :posts, source: :author, class_name: 'User'
  has_many :post_characters, -> { distinct }, through: :posts, source: :character, class_name: 'Character'

  has_one :first_post, foreign_key: :id, primary_key: :first_post_id, class_name: 'Post', inverse_of: :conversation
  has_one :last_post, foreign_key: :id, primary_key: :last_post_id, class_name: 'Post', inverse_of: :conversation

  accepts_nested_attributes_for :posts, limit: 1

  indexable primary: :title

  validates :title, presence: true
  validates :author, presence: true
  validates :locked_by, presence: true, if: :locked?
  validates :section, presence: true
  validates :posts, presence: true

  before_validation :set_first_post_author, on: :create

  before_save :set_locked_at, if: -> { locked_changed?(to: true) }

  before_commit :set_posts_counts
  before_commit :set_conversations_count

  scope :visible, -> {
    not_deleted.where(section: Section.visible)
  }

  scope :recently_active, -> {
    order(last_active_at: :desc).where(Conversation.arel_table[:last_active_at]
                                                   .gteq(1.day.ago))
  }

protected

  def countable_posts
    posts.not_deleted
  end

private

  def set_locked_at
    self.locked_at = Time.current
  end

  def set_first_post_author
    posts.first&.author = author
  end

  def set_posts_counts
    section.set_posts_count unless section.destroyed?
    post_authors.set_posts_counts
    post_characters.set_posts_counts
  end

  def set_conversations_count
    section.update_columns(conversations_count: section.conversations.not_deleted.count) unless section.destroyed?
  end
end
