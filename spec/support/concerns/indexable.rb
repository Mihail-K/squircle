# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for Indexable do
  let :indexable do
    build described_class.model_name.singular
  end

  it 'queues an index to be created on create' do
    expect do
      indexable.save
    end.to have_enqueued_job(IndexJob).on_queue('medium')
  end

  it 'queues the index to be updated when it becomes stale' do
    indexable.save

    expect do
      indexable.attributes = attributes_for(described_class.model_name.singular)
      indexable.save
    end.to have_enqueued_job(IndexJob).on_queue('medium')
  end
end
