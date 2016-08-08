class Character < ActiveRecord::Base
  belongs_to :user, counter_cache: :characters_count, inverse_of: :characters
  belongs_to :creator, counter_cache: :created_characters_count, class_name: 'User'

  has_many :posts, -> { visible }, inverse_of: :character

  serialize :gallery_images, Array

  mount_uploader :avatar, AvatarUploader
  mount_uploaders :gallery_images, AvatarUploader

  validates :name, presence: true
  validates :user, presence: true, on: :create
  validates :creator, presence: true
  validates :gallery_images, length: { maximum: 5 }

  before_validation :set_creator_from_user, if: 'creator.nil?'

  scope :visible, -> {
    where deleted: false
  }

  def set_creator_from_user
    self.creator = user
  end
end
