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
#  locked_on      :datetime
#  locked_by_id   :integer
#  last_active_at :datetime
#  section_id     :integer          not null
#  deleted_by_id  :integer
#  deleted_at     :datetime
#
# Indexes
#
#  index_conversations_on_author_id      (author_id)
#  index_conversations_on_deleted_by_id  (deleted_by_id)
#  index_conversations_on_locked_by_id   (locked_by_id)
#  index_conversations_on_section_id     (section_id)
#
# Foreign Keys
#
#  fk_rails_23b24f1951  (locked_by_id => users.id)
#  fk_rails_a10f02b3e3  (deleted_by_id => users.id)
#  fk_rails_add3e5cc0c  (section_id => sections.id)
#  fk_rails_c9ec5eb09c  (author_id => users.id)
#

class Conversation < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :locked_by, class_name: 'User'
  belongs_to :section, inverse_of: :conversations

  has_many :posts, inverse_of: :conversation, dependent: :destroy

  has_many :post_authors, -> { distinct }, through: :posts, source: :author, class_name: 'User'
  has_many :post_characters, -> { distinct }, through: :posts, source: :character, class_name: 'Character'

  has_one :first_post, -> { first_posts.not_deleted }, class_name: 'Post'
  has_one :last_post, -> { last_posts.not_deleted }, class_name: 'Post'

  accepts_nested_attributes_for :posts, limit: 1, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true
  validates :locked_by, presence: true, if: :locked?
  validates :section, presence: true

  before_save :set_locked_on_timestamp, if: -> { locked_changed?(to: true) }

  before_commit :set_posts_counts
  before_commit :set_conversations_count

  scope :visible, -> {
    not_deleted.where(section: Section.visible)
  }

  scope :recently_active, -> {
    order(last_active_at: :desc).where Conversation.arel_table[:last_active_at]
                                                   .gteq(1.day.ago)
  }

private

  def set_locked_on_timestamp
    self.locked_on = Time.zone.now
  end

  def set_posts_counts
    section.update_columns(posts_count: section.posts.visible.count) unless section.destroyed?
    post_authors.find_each do |author|
      author.update_columns(posts_count: author.posts.visible.count)
    end
    post_characters.find_each do |character|
      character.update_columns(posts_count: character.posts.visible.count)
    end
  end

  def set_conversations_count
    section.update_columns(conversations_count: section.conversations.not_deleted.count) unless section.destroyed?
  end
end
