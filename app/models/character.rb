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
#  display_name   :string
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
  include Indexable
  include PostCountable
  include SoftDeletable

  belongs_to :user, inverse_of: :characters, touch: true
  belongs_to :creator, counter_cache: :created_characters_count, class_name: 'User', touch: true

  has_many :posts, inverse_of: :character

  mount_uploader :avatar, AvatarUploader
  # process_in_background :avatar

  serialize :gallery_images, Array
  mount_uploaders :gallery_images, AvatarUploader

  indexable primary: :name, secondary: %i(title display_name), tertiary: :description

  validates :name, presence: true, length: { maximum: 30 }
  validates :title, length: { in: 5..100 }
  validates :description, length: { maximum: 10_000 }

  validates :user, presence: true, on: :create
  validates :creator, presence: true
  validates :gallery_images, length: { maximum: 5 }

  before_save :set_display_name, if: -> { new_record? || user_id_changed? }

  before_commit :set_characters_count, unless: -> { user.destroyed? }

  after_commit :update_character_name_caches, on: :update, if: :name_previously_changed?

private

  def set_display_name
    self.display_name = user&.display_name
  end

  def set_characters_count
    user.update_columns(characters_count: user.characters.not_deleted.count)
  end

  def update_character_name_caches
    CharacterNameJob.perform_later(id)
  end
end
