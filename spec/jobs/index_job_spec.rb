# frozen_string_literal: true
require 'rails_helper'

RSpec.describe IndexJob, type: :job do
  let! :post do
    create :post
  end

  it 'creates a new index if no index exists' do
    expect do
      IndexJob.perform_now(post.id, post.class.name)
    end.to change { Index.count }.by(1)
  end

  it 'updates existing existing index when possible' do
    create :index, indexable: post

    post.attributes = attributes_for(:post)
    post.save

    expect do
      IndexJob.perform_now(post.id, post.class.name)
    end.to change { post.index.reload.version }.by(1)
  end

  it 'does nothing if the index is already up to date' do
    create :index, indexable: post

    expect do
      IndexJob.perform_now(post.id, post.class.name)
    end.not_to change { post.index.reload.version }
  end
end
