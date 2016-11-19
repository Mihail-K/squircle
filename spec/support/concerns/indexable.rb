# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for Indexable do
  let :indexable do
    create described_class.model_name.singular
  end

  let :attributes do
    attributes_for(described_class.model_name.singular)
  end

  context 'without an index' do
    before :each do
      indexable
      clear_jobs
    end

    it 'queues a new index to be created' do
      expect do
        indexable.save
      end.to have_enqueued_job(IndexJob).on_queue('medium')
        .with(indexable.id, indexable.class.name)
    end
  end

  context 'with an existing index' do
    before :each do
      create :index, indexable: indexable
    end

    it 'queues the index to be updated when it becomes stale' do
      expect do
        indexable.attributes = attributes
        indexable.save
      end.to have_enqueued_job(IndexJob).on_queue('medium')
        .with(indexable.id, indexable.class.name)
    end

    it "doesn't queue index updates if no indexed changes were made" do
      expect do
        indexable.save
      end.not_to have_enqueued_job(IndexJob).on_queue('medium')
    end
  end
end
