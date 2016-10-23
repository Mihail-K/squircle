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
#
# Indexes
#
#  index_sections_on_creator_id     (creator_id)
#  index_sections_on_deleted_by_id  (deleted_by_id)
#  index_sections_on_title          (title)
#
# Foreign Keys
#
#  fk_rails_477a079ad2  (deleted_by_id => users.id)
#  fk_rails_f190a7bfc1  (creator_id => users.id)
#

class Section < ApplicationRecord
  include PostCountable
  include SoftDeletable

  belongs_to :creator, class_name: 'User'

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
