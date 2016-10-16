# frozen_string_literal: true
class UnbanJob < ApplicationJob
  queue_as :medium

  def perform
    User.banned.no_active_bans.find_each do |user|
      user.roles.delete(banned)
      user.update_columns(banned: false)
    end
  end

private

  def banned
    @banned ||= Role.find_by!(name: 'banned')
  end
end
