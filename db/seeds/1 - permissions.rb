
# - Ban Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted bans.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view visible bans.
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
    Permits the user to edit the details of a ban.
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
    Permits the user to edit all characters.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit characters that they own.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete all characters.
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

Permissible::Permission.find_or_create_by! name: :create_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update all conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update their own conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete all conversations.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_owned_conversations do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete their own conversations.
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
    Permits the user to view visible posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :ignore_flood_limit do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to ignore the flood limit.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit their own posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit all posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_owned_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user the delete their own posts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_posts do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete all posts.
  TEXT
end

# - Report Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view all visible reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :view_owned_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view their own reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit all reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_owned_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit their own reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete all reports.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_owned_reports do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete their own reports.
  TEXT
end

# - Role Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_roles do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted roles.
  TEXT
end

# - Section Permissions - #

Permissible::Permission.find_or_create_by! name: :view_deleted_sections do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted forum sections.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :create_sections do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new forum sections.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_sections do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit forum sections.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_sections do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete forum sections.
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
    Permits the user to view visible users.
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
    Permits the user to update all accounts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :update_self do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update their own account.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete all accounts.
  TEXT
end

Permissible::Permission.find_or_create_by! name: :delete_self do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete their own account.
  TEXT
end
