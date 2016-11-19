# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Index, type: :model do
  let :index do
    build :index
  end

  it 'has a valid factory' do
    expect(index).to be_valid
  end

  it 'is invalid without an indexable' do
    index.indexable = nil
    expect(index).to be_invalid
  end

  it 'is invalid without a primary index' do
    index.indexable = nil
    expect(index).to be_invalid
  end

  it 'is invalid with a duplicate indexable' do
    index.save
    expect(build(:index, indexable: index.indexable)).to be_invalid
  end
end
