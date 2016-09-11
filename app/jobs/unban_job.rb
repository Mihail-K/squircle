class UnbanJob
  @queue = :medium

  def self.perform
    User.banned.no_active_bans.find_each do |user|
      user.roles.delete(banned)
    end
  end

private

  def self.banned
    @banned ||= Role.find_by!(name: 'banned')
  end
end
