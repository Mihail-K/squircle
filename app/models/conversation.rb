# == Schema Information
#
# Table name: conversations
#
#  id          :integer          not null, primary key
#  posts_count :integer          default(0), not null
#  deleted     :boolean          default(FALSE), not null
#  author_id   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  views_count :integer          default(0), not null
#  title       :string           not null
#
# Indexes
#
#  index_conversations_on_author_id  (author_id)
#

class Conversation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'

  has_many :posts, -> { visible }, inverse_of: :postable

  has_many :post_authors, -> { visible.distinct }, through: :posts,
                                                   source: :author,
                                                   class_name: 'User'
  has_many :post_characters, -> { visible.distinct }, through: :posts,
                                                      source: :character,
                                                      class_name: 'Character'

  has_one :first_post, -> { visible.order(created_at: :asc) }, class_name: 'Post'
  has_one :last_post, -> { visible.order(created_at: :desc) }, class_name: 'Post'

  accepts_nested_attributes_for :first_post, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true
  validates :first_post, presence: true, on: :create

  before_validation :set_conversation_in_first_post, on: :create, if: -> {
    first_post.present?
  }

  before_validation :set_author_in_first_post, on: :create, unless: :author
  before_validation :set_title_from_first_post, on: :create, unless: :title?

  scope :visible, -> {
    where deleted: false
  }

  def set_conversation_in_first_post
    first_post.conversation = self
  end

  def set_author_in_first_post
    first_post.author = author
  end

  def set_title_from_first_post
    self.title = first_post.title
  end
end
