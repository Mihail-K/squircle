# frozen_string_literal: true
# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  friend_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_friendships_on_friend_id              (friend_id)
#  index_friendships_on_user_id                (user_id)
#  index_friendships_on_user_id_and_friend_id  (user_id,friend_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_d78dc9c7fd  (friend_id => users.id)
#  fk_rails_e3733b59b7  (user_id => users.id)
#

class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  has_many :notifications, as: :sourceable

  validates :user, presence: true
  validates :friend, presence: true
  validates :user, uniqueness: { scope: :friend }

  validate :friend_is_not_user, if: -> { user.present? && friend.present? }

  after_create :create_notification

private

  def friend_is_not_user
    errors.add :base, :cant_self_friend if user == friend
  end

  def create_notification
    notifications.find_or_create_by(user: friend, targetable: user) do |notification|
      notification.title = I18n.t('notifications.friendship', name: user.display_name)
    end
  end
end
