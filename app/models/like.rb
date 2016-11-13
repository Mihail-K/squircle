# frozen_string_literal: true
# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  likeable_type :string           not null
#  likeable_id   :integer          not null
#  user_id       :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_likes_on_likeable_id_and_likeable_type_and_user_id  (likeable_id,likeable_type,user_id) UNIQUE
#  index_likes_on_likeable_type_and_likeable_id              (likeable_type,likeable_id)
#  index_likes_on_user_id                                    (user_id)
#
# Foreign Keys
#
#  fk_rails_1e09b5dabf  (user_id => users.id)
#

class Like < ApplicationRecord
  ALLOWED_TYPES = %w(Post).freeze

  belongs_to :likeable, polymorphic: true, inverse_of: :likes, counter_cache: :likes_count
  belongs_to :user

  has_many :notifications, as: :sourceable

  validates :user, presence: true, uniqueness: { scope: :likeable }
  validates :likeable, presence: true

  after_create :create_notification

  scope :preview, -> {
    where(Like.arel_table[:row_num].lteq(3)).from(select(<<-SQL.squish), :likes)
      likes.*,
      row_number() OVER (PARTITION BY likes.likeable_id, likes.likeable_type ORDER BY likes.created_at ASC) AS row_num
    SQL
  }

private

  def create_notification
    notifications.find_or_create_by(user: likeable.author, targetable: likeable) do |notification|
      notification.title = I18n.t('notifications.like', name: user.display_name,
                                                        likeable: likeable.class.model_name.singular)
    end
  end
end
