
# frozen_string_literal: true
{
  # - Bans - #
  view_deleted_bans:          :view_bans,
  view_bans:                  :view_owned_bans,

  # - Characters - #
  view_deleted_characters:    :view_characters,
  update_characters:          :update_owned_characters,
  delete_characters:          :delete_owned_characters,

  # - Conversations - #
  view_deleted_conversations: :view_conversations,

  # - Likes - #
  delete_likes:               :delete_owned_likes,

  # - Reports - #
  view_deleted_reports:       :view_reports,
  view_reports:               :view_owned_reports,
  update_reports:             :update_owned_reports,
  delete_reports:             :delete_owned_reports,

  # - Posts - #
  view_deleted_posts:         :view_posts,
  update_posts:               :update_owned_posts,
  delete_posts:               :delete_owned_posts,

  # - Users - #
  view_deleted_users:         :view_users,
  update_users:               :update_self,
  delete_users:               :delete_self
}.each do |name, implied_names|
  permission = Permissible::Permission.find_by!(name: name)

  Array.wrap(implied_names).each do |implied_name|
    implied = Permissible::Permission.find_by!(name: implied_name)
    next if permission.implied_permissions.exists?(id: implied)

    permission.implied_permissions << implied
  end
end
