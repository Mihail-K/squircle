# frozen_string_literal: true
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
#  parent_id           :integer
#
# Indexes
#
#  index_sections_on_creator_id     (creator_id)
#  index_sections_on_deleted_by_id  (deleted_by_id)
#  index_sections_on_parent_id      (parent_id)
#  index_sections_on_title          (title)
#
# Foreign Keys
#
#  fk_rails_414a4067c5  (parent_id => sections.id)
#  fk_rails_477a079ad2  (deleted_by_id => users.id)
#  fk_rails_f190a7bfc1  (creator_id => users.id)
#

class Section < ApplicationRecord
  include PostCountable
  include SoftDeletable

  belongs_to :creator, class_name: 'User'
  belongs_to :parent, class_name: 'Section', inverse_of: :children

  has_many :children, class_name: 'Section', foreign_key: :parent_id,
                      inverse_of: :parent, dependent: :restrict_with_error

  has_many :conversations, inverse_of: :section
  has_many :posts, through: :conversations

  has_many :post_authors, -> { distinct }, through: :conversations
  has_many :post_characters, -> { distinct }, through: :conversations

  validates :title, presence: true
  validates :description, length: { maximum: 1000 }
  validates :creator, presence: true

  before_commit :update_post_counts, if: -> { previous_changes.key?(:deleted) }

  scope :visible, -> { not_deleted }

private

  def update_post_counts
    SectionPostsCountJob.perform_later(id)
  end
end
