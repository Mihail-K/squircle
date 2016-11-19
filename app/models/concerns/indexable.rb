# frozen_string_literal: true
module Indexable
  extend ActiveSupport::Concern

  included do
    has_one :index, as: :indexable, inverse_of: :indexable, dependent: :destroy

    after_save :remove_index, if: -> { has_attribute?(:deleted) && deleted_changed?(to: true) }
    after_commit :queue_index_update, on: %i(create update), if: -> { index.nil? || index_stale? }

    def self.indexable(**options)
      @indexable_attributes = options.slice(:primary, :secondary, :tertiary).freeze
    end

    def self.indexable_attributes
      @indexable_attributes || {}
    end
  end

  delegate :indexable_attributes, to: :class

  def index_attributes(rank)
    indexable_attributes.present? ? Array.wrap(indexable_attributes[rank]).reject(&:blank?) : []
  end

  def index_values(rank)
    index_attributes(rank).map { |attribute| send(attribute) }.flatten
  end

  def remove_index
    index&.destroy
  end

  def queue_index_update
    IndexJob.perform_later(id, self.class.name) unless has_attribute?(:deleted) && deleted?
  end

  def index_stale?
    indexable_attributes.values.flatten.any? { |attribute| previous_changes.key?(attribute) }
  end
end
