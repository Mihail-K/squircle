
USER = %w(
  view_own_bans
)

MODERATOR = USER + %w(
  view_others_bans create_bans update_bans
)

ADMIN = MODERATOR + %w(
  view_deleted_bans delete_bans
)

{ user: USER, moderator: MODERATOR, admin: ADMIN }.each do |role, permissions|
  role = Role.find_by!(name: role)
  permissions.each do |permission|
    next if role.permissions.exists?(name: permission)
    role.permissions << Permission.find_by!(name: permission)
  end
end
