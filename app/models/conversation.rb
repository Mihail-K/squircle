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

class Conversation < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :locked_by, class_name: 'User'
  belongs_to :section, inverse_of: :conversations, counter_cache: :conversations_count

  has_many :posts, inverse_of: :conversation

  has_many :post_authors, -> { distinct }, through: :posts, source: :author, class_name: 'User'
  has_many :post_characters, -> { distinct }, through: :posts, source: :character, class_name: 'Character'

  has_one :first_post, -> { first_posts.visible }, class_name: 'Post'
  has_one :last_post, -> { last_posts.visible }, class_name: 'Post'

  accepts_nested_attributes_for :posts, limit: 1, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true
  validates :locked_by, presence: true, if: :locked?
  validates :section, presence: true

  before_validation :set_first_post_author, on: :create
  before_validation :set_title_from_first_post, on: :create, unless: :title?

  before_save :set_locked_on_timestamp, if: -> { locked_changed?(to: true) }

  scope :hidden, -> {
    where(deleted: true).union(
      joins(:section).merge(Section.hidden)
    )
  }

  scope :visible, -> {
    where(deleted: false).joins(:section).merge(Section.visible)
  }

  scope :active, -> {
    visible.where(locked: false)
  }

  scope :recently_active, -> {
    order(last_active_at: :desc).where Conversation.arel_table[:last_active_at]
                                                   .gteq(1.day.ago)
  }

  def active?
    !locked? && !deleted? && !section.try(:deleted?)
  end

private

  def set_first_post_author
    posts.first.author = author if posts.first.present?
  end

  def set_title_from_first_post
    self.title = posts.first.title if posts.first.present?
  end

  def set_locked_on_timestamp
    self.locked_on = Time.zone.now
  end
end
