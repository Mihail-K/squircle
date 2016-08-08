class Conversation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'

  has_many :posts, -> { visible },
                   as: :postable,
                   inverse_of: :postable

  has_many :post_authors, -> { distinct },
                          through: :posts,
                          source: :author,
                          class_name: 'User'
  has_many :post_characters, -> { distinct },
                             through: :posts,
                             source: :character,
                             class_name: 'Character'

  has_one :first_post, -> { visible.order(created_at: :asc) },
                       as: :postable,
                       foreign_key: :postable_id,
                       foreign_type: :postable_type,
                       class_name: 'Post'
  has_one :last_post, -> { visible.order(created_at: :desc) },
                      as: :postable,
                      foreign_key: :postable_id,
                      foreign_type: :postable_type,
                      class_name: 'Post'

  accepts_nested_attributes_for :first_post, reject_if: :all_blank

  validates :author, presence: true
  validates :first_post, presence: true, on: :create

  before_validation on: :create, if: -> { self.first_post.present? } do
    self.first_post.postable ||= self
    self.author ||= first_post.author
  end

  scope :visible, -> {
    where deleted: false
  }
end
