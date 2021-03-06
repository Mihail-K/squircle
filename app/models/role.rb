# frozen_string_literal: true
# == Schema Information
#
# Table name: roles
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
#  index_roles_on_deleted        (deleted)
#  index_roles_on_deleted_by_id  (deleted_by_id)
#  index_roles_on_name           (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_9dfc4563d8  (deleted_by_id => users.id)
#

class Role < ApplicationRecord
  include Permissible::Model
  include SoftDeletable

  has_and_belongs_to_many :users

  accepts_nested_attributes_for :role_permissions, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 1000 }
end
