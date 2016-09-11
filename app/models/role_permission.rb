# == Schema Information
#
# Table name: role_permissions
#
#  id            :integer          not null, primary key
#  role_id       :integer          not null
#  permission_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  value         :string           default("allow"), not null
#  deleted       :boolean          default(FALSE), not null
#  deleted_by_id :integer
#  deleted_at    :datetime
#
# Indexes
#
#  index_role_permissions_on_deleted_by_id              (deleted_by_id)
#  index_role_permissions_on_permission_id              (permission_id)
#  index_role_permissions_on_role_id                    (role_id)
#  index_role_permissions_on_role_id_and_permission_id  (role_id,permission_id) UNIQUE
#  index_role_permissions_on_value                      (value)
#

class RolePermission < ApplicationRecord
  belongs_to :role
  belongs_to :permission

  enum value: {
    allow:  'allow',
    forbid: 'forbid'
  }

  validates :role, presence: true
  validates :permission, presence: true
  validates :value, presence: true

  scope :permission, -> (permission) {
    if permission.is_a?(Permission)
      where(permission: permission)
    else
      joins(:permission).where(permissions: { name: permission })
    end
  }
end
