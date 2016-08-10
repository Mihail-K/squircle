# == Schema Information
#
# Table name: characters
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  title          :string
#  description    :string
#  user_id        :integer
#  creator_id     :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted        :boolean          default(FALSE), not null
#  posts_count    :integer          default(0), not null
#  avatar         :string
#  gallery_images :string
#
# Indexes
#
#  index_characters_on_creator_id  (creator_id)
#  index_characters_on_name        (name)
#  index_characters_on_user_id     (user_id)
#

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
