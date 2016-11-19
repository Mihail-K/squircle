# frozen_string_literal: true
# == Schema Information
#
# Table name: indices
#
#  id             :integer          not null, primary key
#  indexable_type :string           not null
#  indexable_id   :integer          not null
#  primary        :text             not null, is an Array
#  secondary      :text             is an Array
#  tertiary       :text             is an Array
#  version        :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_indices_on_indexable_type_and_indexable_id  (indexable_type,indexable_id) UNIQUE
#  index_indices_on_primary                          (primary)
#  index_indices_on_secondary                        (secondary)
#  index_indices_on_tertiary                         (tertiary)
#

class Index < ApplicationRecord
  belongs_to :indexable, polymorphic: true, inverse_of: :index

  validates :indexable, presence: true
  validates :indexable_id, uniqueness: { scope: :indexable_type }
  validates :primary, presence: true

  before_validation :populate, if: -> { indexable.present? }

  before_save :increment_version, if: :changed?

  def populate
    %i(primary secondary tertiary).each do |rank|
      self[rank] = indexable.index_values(rank)
    end
  end

  def increment_version
    self.version += 1
  end
end
