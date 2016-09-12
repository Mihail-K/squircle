
{
  user: {
    # - Bans - #
    view_owned_bans:            :allow,
    # - Characters - #
    view_characters:            :allow,
    create_characters:          :allow,
    update_owned_characters:    :allow,
    delete_owned_characters:    :allow,
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
    delete_characters:          :allow
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
    # - Users - #
    view_deleted_users:         :allow,
    view_users_personal_fields: :allow,
    create_users:               :allow,
    update_users:               :allow,
    delete_users:               :allow
  },
  banned: {
    # - Characters - #
    create_characters:          :forbid,
    update_characters:          :forbid,
    delete_characters:          :forbid,
    # - Users - #
    update_users:               :forbid,
    delete_users:               :forbid
  }
}.each do |role, permissions|
  role = Role.find_by!(name: role)
  permissions.each do |name, value|
    permission = Permission.find_by!(name: name)
    role.role_permissions.find_or_create_by!(permission: permission) do |role_permission|
      role_permission.value = value
    end
  end
end
