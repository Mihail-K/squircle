class Conversation < ActiveRecord::Base
  belongs_to :author, class_name: 'User'

  has_many :posts, as: :postable, inverse_of: :postable
  has_many :post_authors, -> { distinct }, through: :posts,
                                           source: :author,
                                           class_name: 'User'
  has_many :post_characters, -> { distinct }, through: :posts,
                                              source: :character,
                                              class_name: 'Character'

  has_one :first_post, as: :postable,
                       foreign_key: :postable_id,
                       foreign_type: :postable_type,
                       class_name: 'Post'
  has_one :last_post, -> { order created_at: :desc }, as: :postable,
                                                      foreign_key: :postable_id,
                                                      foreign_type: :postable_type,
                                                      class_name: 'Post'

  accepts_nested_attributes_for :posts, limit: 1, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true
  validates :posts, presence: true, on: :create

  before_validation on: :create, unless: :title? do
    self.title ||= posts.first.try(:title)
  end

  scope :visible, -> {
    where deleted: false
  }
end
