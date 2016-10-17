# frozen_string_literal: true
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
#  deleted_by_id  :integer
#  deleted_at     :datetime
#
# Indexes
#
#  index_characters_on_creator_id     (creator_id)
#  index_characters_on_deleted_by_id  (deleted_by_id)
#  index_characters_on_name           (name)
#  index_characters_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_53a8ea746c  (user_id => users.id)
#  fk_rails_b2c2114869  (creator_id => users.id)
#  fk_rails_b84e8f3791  (deleted_by_id => users.id)
#

class Character < ApplicationRecord
  belongs_to :user, counter_cache: :characters_count, inverse_of: :characters, touch: true
  belongs_to :creator, counter_cache: :created_characters_count, class_name: 'User', touch: true

  has_many :posts, inverse_of: :character

  mount_uploader :avatar, AvatarUploader
  process_in_background :avatar

  serialize :gallery_images, Array
  mount_uploaders :gallery_images, AvatarUploader

  validates :name, presence: true, length: { maximum: 30 }
  validates :title, length: { in: 5..100 }
  validates :description, length: { maximum: 10_000 }

  validates :user, presence: true, on: :create
  validates :creator, presence: true
  validates :gallery_images, length: { maximum: 5 }
end
