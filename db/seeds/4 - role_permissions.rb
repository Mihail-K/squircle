
{
  user: {
    # - Bans - #
    view_owned_bans:            :allow,
    # - Characters - #
    view_characters:            :allow,
    create_characters:          :allow,
    update_owned_characters:    :allow,
    delete_owned_characters:    :allow,
    # - Conversations - #
    view_conversations:         :allow,
    create_conversations:       :allow,
    update_owned_conversations: :allow,
    # - Posts - #
    view_posts:                 :allow,
    create_posts:               :allow,
    update_owned_posts:         :allow,
    delete_owned_posts:         :allow,
    # - Reports - #
    view_owned_reports:         :allow,
    create_reports:             :allow,
    update_owned_reports:       :allow,
    # - Users - #
    view_users:                 :allow,
    update_self:                :allow,
    delete_self:                :allow
  },
  moderator: {
    # - Bans - #
    view_bans:                  :allow,
    create_bans:                :allow,
    update_bans:                :allow,
    # - Characters - #
    update_characters:          :allow,
    delete_characters:          :allow,
    # - Conversations - #
    view_deleted_conversations: :allow,
    lock_conversations:         :allow,
    create_conversations:       :allow,
    update_conversations:       :allow,
    delete_conversations:       :allow,
    # - Posts - #
    view_deleted_posts:         :allow,
    create_posts:               :allow,
    update_posts:               :allow,
    delete_posts:               :allow,
    # - Reports - #
    view_reports:               :allow,
    create_reports:             :allow,
    update_reports:             :allow
  },
  admin: {
    # - Bans - #
    view_deleted_bans:          :allow,
    create_bans:                :allow,
    update_bans:                :allow,
    delete_bans:                :allow,
    # - Characters - #
    view_deleted_characters:    :allow,
    update_characters:          :allow,
    delete_characters:          :allow,
    # - Conversations - #
    view_deleted_conversations: :allow,
    lock_conversations:         :allow,
    create_conversations:       :allow,
    update_conversations:       :allow,
    delete_conversations:       :allow,
    # - Posts - #
    view_deleted_posts:         :allow,
    ignore_flood_limit:         :allow,
    create_posts:               :allow,
    update_posts:               :allow,
    delete_posts:               :allow,
    # - Reports - #
    view_deleted_reports:       :allow,
    create_reports:             :allow,
    update_reports:             :allow,
    delete_reports:             :allow,
    # - Roles - #
    view_deleted_roles:         :allow,
    # - Sections - #
    view_deleted_sections:      :allow,
    create_sections:            :allow,
    update_sections:            :allow,
    delete_sections:            :allow,
    # - Users - #
    view_deleted_users:         :allow,
    view_users_personal_fields: :allow,
    create_users:               :allow,
    update_users:               :allow,
    delete_users:               :allow
  },
  banned: {
    # - Bans - #
    create_bans:                :forbid,
    update_bans:                :forbid,
    delete_bans:                :forbid,
    # - Characters - #
    create_characters:          :forbid,
    update_characters:          :forbid,
    delete_characters:          :forbid,
    # - Conversations - #
    create_conversations:       :forbid,
    update_conversations:       :forbid,
    delete_conversations:       :forbid,
    # - Posts - #
    create_posts:               :forbid,
    update_posts:               :forbid,
    delete_posts:               :forbid,
    # - Reports - #
    create_reports:             :forbid,
    update_reports:             :forbid,
    delete_reports:             :forbid,
    # - Users - #
    create_users:               :forbid,
    update_users:               :forbid,
    delete_users:               :forbid
  }
}.each do |role, permissions|
  role = Role.find_by!(name: role)
  permissions.each do |name, value|
    permission = Permissible::Permission.find_by!(name: name)
    role.role_permissions.find_or_create_by!(permission: permission) do |role_permission|
      role_permission.value = value
    end
  end
end
