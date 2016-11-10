# frozen_string_literal: true
class UserBucketJob < ApplicationJob
  queue_as :low

  def perform
    mark_active
    mark_inactive
    mark_lost
  end

private

  def mark_active
    User.where.not(bucket: 'active')
        .where(User.arel_table[:last_active_at].gt(30.days.ago))
        .find_each do |user|
      user.update(bucket: 'active')
    end
  end

  def mark_inactive
    User.where.not(bucket: 'inactive')
        .where(User.arel_table[:last_active_at].between(90.days.ago..30.days.ago))
        .find_each do |user|
      user.update(bucket: 'inactive')
    end
  end

  def mark_lost
    User.where.not(bucket: 'lost')
        .where(User.arel_table[:last_active_at].lt(90.days.ago))
        .find_each do |user|
      user.update(bucket: 'lost')
    end
  end
end
