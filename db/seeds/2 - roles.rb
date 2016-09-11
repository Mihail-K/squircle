
Role.find_or_create_by! name: 'user' do |role|
  role.description = <<-TEXT.squish
    The default role for all users.
  TEXT
end

Role.find_or_create_by! name: 'moderator' do |role|
  role.description = <<-TEXT.squish
    A privileged role for forum moderators.
  TEXT
end

Role.find_or_create_by! name: 'admin' do |role|
  role.description = <<-TEXT.squish
    The highest privileged for forum admins.
  TEXT
end

Role.find_or_create_by! name: 'banned' do |role|
  role.description = <<-TEXT.squish
    A restrictive role for banned users.
  TEXT
end
