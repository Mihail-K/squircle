# == Schema Information
#
# Table name: conversations
#
#  id                  :integer          not null, primary key
#  posts_count         :integer          default(0), not null
#  deleted             :boolean          default(FALSE), not null
#  author_id           :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  views_count         :integer          default(0), not null
#  title               :string           not null
#  locked              :boolean          default(FALSE), not null
#  locked_on           :datetime
#  locked_by_id        :integer
#  visible_posts_count :integer          default(0), not null
#  last_active_at      :datetime
#
# Indexes
#
#  index_conversations_on_author_id     (author_id)
#  index_conversations_on_locked_by_id  (locked_by_id)
#

class Conversation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :locked_by, class_name: 'User'

  has_many :posts, inverse_of: :conversation

  has_many :post_authors, -> { distinct }, through: :posts,
                                           source: :author,
                                           class_name: 'User'
  has_many :post_characters, -> { distinct }, through: :posts,
                                              source: :character,
                                              class_name: 'Character'

  has_one :first_post, -> { first_posts }, class_name: 'Post'
  has_one :last_post, -> { last_posts }, class_name: 'Post'

  accepts_nested_attributes_for :posts, limit: 1, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true
  validates :locked_by, presence: true, if: :locked?

  validate :locking_user_is_admin, if: -> { locked_changed? to: true }

  before_validation :set_first_post_author, on: :create, if: 'author.present?'
  before_validation :set_title_from_first_post, on: :create, unless: :title?

  before_save :set_locked_on_timestamp, if: -> { locked_changed? to: true }

  after_create :set_visible_posts_count

  scope :locked,   -> { where locked: true }
  scope :unlocked, -> { where locked: false }
  scope :visible,  -> { where deleted: false }
  scope :deleted,  -> { where deleted: true }

  scope :recently_active, -> {
    order(last_active_at: :desc).where Conversation.arel_table[:last_active_at]
                                                   .gteq(1.day.ago)
  }

  def locking_user_is_admin
    errors.add :locked, 'can only be changed by admins' unless locked_by.try(:admin?)
  end

  def set_first_post_author
    posts.first.author = author
  end

  def set_title_from_first_post
    self.title = posts.first.title
  end

  def set_locked_on_timestamp
    self.locked_on = Time.zone.now
  end

private

  def set_visible_posts_count
    update_columns visible_posts_count: posts.visible.count
  end
end
