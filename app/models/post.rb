class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'User',
                      counter_cache: :posts_count,
                      inverse_of: :posts
  belongs_to :editor, class_name: 'User'
  belongs_to :character, counter_cache: :posts_count,
                         inverse_of: :posts

  belongs_to :postable, polymorphic: true,
                        counter_cache: :posts_count,
                        inverse_of: :posts

  validates :author, presence: true
  validates :postable, presence: true
  validates :body, presence: true, length: { in: 10 .. 10_000 }

  scope :visible, -> {
    where deleted: false
  }
end
