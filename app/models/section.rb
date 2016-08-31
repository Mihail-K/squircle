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
#  visible_posts_count :integer          default(0), not null
#
# Indexes
#
#  index_sections_on_creator_id  (creator_id)
#  index_sections_on_title       (title)
#

class Section < ActiveRecord::Base
  belongs_to :creator, class_name: 'User'

  has_many :conversations, inverse_of: :section
  has_many :posts, through: :conversations

  validates :title, presence: true
  validates :description, length: { in: 5..1000 }
  validates :creator, presence: true

  scope :visible, -> { where(deleted: false) }
end
