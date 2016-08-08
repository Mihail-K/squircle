class Post < ActiveRecord::Base
  belongs_to :poster, class_name: 'User', counter_cache: :posts_count, inverse_of: :posts
  belongs_to :editor, class_name: 'User'
  belongs_to :character, counter_cache: :posts_count, inverse_of: :posts

  validates :poster, presence: true
  validates :body, presence: true, length: { in: 10 .. 10_000 }

  validate :check_flood_limit, on: :create, unless: 'poster.admin?'

  scope :visible, -> {
    where deleted: false
  }

  def check_flood_limit
    if Post.where(posted_id: posted_id).exists? 'created_at > ?', 20.seconds.ago
      errors.add :base, 'you can only post once every 20 seconds'
    end
  end
end
