# == Schema Information
#
# Table name: permissions
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  description   :text
#  deleted       :boolean          default(FALSE), not null
#  deleted_by_id :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_permissions_on_deleted        (deleted)
#  index_permissions_on_deleted_by_id  (deleted_by_id)
#  index_permissions_on_name           (name) UNIQUE
#

class Permission < ApplicationRecord
  has_and_belongs_to_many :roles

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 1000 }
end
