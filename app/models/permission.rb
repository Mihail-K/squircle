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
#  implied_by_id :integer
#
# Indexes
#
#  index_permissions_on_deleted        (deleted)
#  index_permissions_on_deleted_by_id  (deleted_by_id)
#  index_permissions_on_implied_by_id  (implied_by_id)
#  index_permissions_on_name           (name) UNIQUE
#

class Permission < ApplicationRecord
  belongs_to :implied_by, class_name: 'Permission'

  has_many :implied_permissions, class_name: 'Permission', foreign_key: :implied_by_id

  has_many :role_permissions
  has_many :roles, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 1000 }

  scope :implied, -> (name) {
    where(implied_cte(name))
  }

  def implied_by=(value)
    if value.is_a?(Symbol) || value.is_a?(String)
      super Permission.find_by!(name: value)
    else
      super
    end
  end

private

  def self.implied_cte(name)
    permission_tree = Arel::Table.new(:permission_tree)
    p_alias         = Permission.arel_table.alias('p_alias')
    cte_node        = Arel::Nodes::As.new(
      permission_tree,
      Permission.arel_table
                .project(
                  Permission.arel_table[:id],
                  Permission.arel_table[:implied_by_id]
                )
                .where(
                  Permission.arel_table[:name]
                            .eq(name)
                )
                .union(
                  Permission.arel_table
                            .project(p_alias[:id], p_alias[:implied_by_id])
                            .from(p_alias)
                            .join(permission_tree)
                            .on(
                              p_alias[:id].eq(permission_tree[:implied_by_id])
                            )
                )
    )
    Permission.arel_table[:id]
              .in(
                Permission.arel_table
                          .project(permission_tree[:id])
                          .from(permission_tree)
                          .with(cte_node)
              )
  end
end
