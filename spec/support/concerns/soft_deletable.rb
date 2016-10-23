# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples_for SoftDeletable do
  let :model do
    described_class.model_name.singular
  end

  let :record do
    build model, deleted: true, deleted_by: build(:user)
  end

  it 'has a valid factory' do
    expect(record).to be_valid
  end

  it 'sets the deleted_at timestamp on save' do
    record.save
    expect(record).to be_persisted
    expect(record.deleted_at).not_to be_blank
  end

  describe '.deleted' do
    let :record do
      create model, deleted: true, deleted_by: create(:user)
    end

    it 'has a valid factory' do
      expect(record).to be_valid
    end

    it 'includes deleted records' do
      expect(described_class.deleted.where(id: record)).to exist
    end

    it 'does not include records that are un-deleted' do
      record.update deleted: false
      expect(described_class.deleted.where(id: record)).not_to exist
    end
  end

  describe '.not_deleted' do
    let :record do
      create model, deleted: true, deleted_by: create(:user)
    end

    it 'has a valid factory' do
      expect(record).to be_valid
    end

    it 'does not includes deleted records' do
      expect(described_class.not_deleted.where(id: record)).not_to exist
    end

    it 'includes records that are un-deleted' do
      record.update deleted: false
      expect(described_class.not_deleted.where(id: record)).to exist
    end
  end
end
