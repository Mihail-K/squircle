
# - Ban Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted bans.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' bans.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_owned_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view their own bans.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_ban_creator do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view who created a ban.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to ban other users.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to the details of a ban.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete bans.
  TEXT
end

# - Character Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted characters.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view characters.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new characters.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit any character.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit characters that they own.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete any character.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_owned_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete characters that they own.
  TEXT
end

# - Conversation Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :lock_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to lock and unlock conversations.
  TEXT
end

# - Post Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit their own posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit other users' posts.
  TEXT
end

# - User Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted users.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view users.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_users_personal_fields do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' personal account fields.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new users.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update other users' accounts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_self do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update their own account.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete other users' accounts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_self do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete their own account.
  TEXT
end
