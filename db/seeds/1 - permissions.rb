
# - Ban Permissions - #

Permission.find_or_create_by! name: :view_own_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view their own bans.
  TEXT
end

Permission.find_or_create_by! name: :view_others_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view other users' bans.
  TEXT
end

Permission.find_or_create_by! name: :view_deleted_bans do |permission|
  permission.description = <<-TEXT.squish
    Permits the user to view deleted bans.
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
