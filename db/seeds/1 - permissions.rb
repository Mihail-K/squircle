
# - Ban Permissions - #

Permission.find_or_create_by! name: :view_deleted_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted bans.
  TEXT
end

Permission.find_or_create_by! name: :view_bans do |permission|
  permission.implied_by  = :view_deleted_bans
  permission.description = <<-TEXT.squish
    Permits the user to view other users' bans.
  TEXT
end

Permission.find_or_create_by! name: :view_owned_bans do |permission|
  permission.implied_by  = :view_bans
  permission.description = <<-TEXT.squish
    Permits the user to view their own bans.
  TEXT
end

Permission.find_or_create_by! name: :view_ban_creator do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view who created a ban.
  TEXT
end

Permission.find_or_create_by! name: :create_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to ban other users.
  TEXT
end

Permission.find_or_create_by! name: :update_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to the details of a ban.
  TEXT
end

Permission.find_or_create_by! name: :delete_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete bans.
  TEXT
end

# - Character Permissions - #

Permission.find_or_create_by! name: :view_deleted_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted characters.
  TEXT
end

Permission.find_or_create_by! name: :view_characters do |permission|
  permission.implied_by  = :view_deleted_characters
  permission.description = <<-TEXT.squish
    Permits the user to view characters.
  TEXT
end

Permission.find_or_create_by! name: :create_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new characters.
  TEXT
end

Permission.find_or_create_by! name: :update_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to edit any character.
  TEXT
end

Permission.find_or_create_by! name: :update_owned_characters do |permission|
  permission.implied_by  = :update_characters
  permission.description = <<-TEXT.squish
    Permits the user to edit characters that they own.
  TEXT
end

Permission.find_or_create_by! name: :delete_characters do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete any character.
  TEXT
end

Permission.find_or_create_by! name: :delete_owned_characters do |permission|
  permission.implied_by  = :delete_characters
  permission.description = <<-TEXT.squish
    Permits the user to delete characters that they own.
  TEXT
end

# - User Permissions - #

Permission.find_or_create_by! name: :view_deleted_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted users.
  TEXT
end

Permission.find_or_create_by! name: :view_users do |permission|
  permission.implied_by  = :view_deleted_users
  permission.description = <<-TEXT.squish
    Permits the user to view users.
  TEXT
end

Permission.find_or_create_by! name: :view_users_personal_fields do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' personal account fields.
  TEXT
end

Permission.find_or_create_by! name: :create_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to create new users.
  TEXT
end

Permission.find_or_create_by! name: :update_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to update other users' accounts.
  TEXT
end

Permission.find_or_create_by! name: :update_self do |permission|
  permission.implied_by  = :update_users
  permission.description = <<-TEXT.squish
    Permits the user to update their own account.
  TEXT
end

Permission.find_or_create_by! name: :delete_users do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to delete other users' accounts.
  TEXT
end

Permission.find_or_create_by! name: :delete_self do |permission|
  permission.implied_by  = :delete_users
  permission.description = <<-TEXT.squish
    Permits the user to delete their own account.
  TEXT
end
