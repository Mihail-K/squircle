# frozen_string_literal: true
# == Schema Information
#
# Table name: configs
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  value      :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_configs_on_key  (key) UNIQUE
#

class Config < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  after_commit :purge_cache

  def self.[](key)
    Rails.cache.fetch(config: key) do
      Config.find_by(key: key)&.value
    end
  end

private

  def purge_cache
    Rails.cache.delete(config: key)
  end
end
