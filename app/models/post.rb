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

  belongs_to :author, class_name: 'User',
                      counter_cache: :posts_count,
                      inverse_of: :posts
  belongs_to :editor, class_name: 'User'
  belongs_to :character, counter_cache: :posts_count,
                         inverse_of: :posts

  belongs_to :conversation, counter_cache: :posts_count,
                            inverse_of: :posts

  delegate :locked?, to: :conversation, allow_nil: true

  validates :author, presence: true
  validates :conversation, presence: true
  validates :body, presence: true, length: { in: 10 .. 10_000 }

  validate :character_ownership, on: :create, if: :character, unless: 'author.admin?'
  validate if: %i(deleted? editor_id_changed?), unless: 'author.admin?' do
    errors.add :base, 'you cannot edit deleted posts'
  end

  formattable :body

  after_save :update_visible_posts_count, if: :deleted_changed?
  after_destroy :update_visible_posts_count

  scope :visible, -> {
    where deleted: false
  }

  def character_ownership
    unless author.characters.exists? id: character_id
      errors.add :base, 'you cannot make posts as this character'
    end
  end

  def editable_by?(user)
    return true if user.try(:admin?)
    author_id == user.try(:id) && !user.try(:banned?)
  end

private

  def update_visible_posts_count
    author.update_columns visible_posts_count: author.posts.visible.count
    conversation.update_columns visible_posts_count: conversation.posts.visible.count
  end
end
