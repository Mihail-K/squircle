# == Schema Information
#
# Table name: sections
#
#  id                  :integer          not null, primary key
#  title               :string           not null
#  description         :text
#  logo                :string
#  conversations_count :integer          default(0), not null
#  deleted             :boolean          default(FALSE), not null
#  creator_id          :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  posts_count         :integer          default(0), not null
#  deleted_by_id       :integer
#  deleted_at          :datetime
#
# Indexes
#
#  index_sections_on_creator_id     (creator_id)
#  index_sections_on_deleted_by_id  (deleted_by_id)
#  index_sections_on_title          (title)
#

class Section < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  has_many :conversations, inverse_of: :section
  has_many :posts, through: :conversations

  validates :title, presence: true
  validates :description, length: { maximum: 1000 }
  validates :creator, presence: true
end
