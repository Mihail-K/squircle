require 'rails_helper'

RSpec.shared_examples_for ApplicationRecord do
  let :model do
    described_class.model_name.singular
  end

  let :record do
    build model, deleted: true, deleted_by: build(:user)
  end

  it 'has a valid factory' do
    expect(record).to be_valid
  end

  it 'is not valid without specifying the deleting user' do
    record.deleted_by = nil
    expect(record).not_to be_valid
  end

  it 'sets the deleted_at timestamp on save' do
    record.save
    expect(record).to be_persisted
    expect(record.deleted_at).not_to be_blank
  end

  describe '.hidden' do
    let :record do
      create model, deleted: true, deleted_by: create(:user)
    end

    it 'has a valid factory' do
      expect(record).to be_valid
    end

    it 'includes deleted records' do
      expect(described_class.hidden.where(id: record)).to exist
    end

    it 'does not include records that are un-deleted' do
      record.update deleted: false
      expect(described_class.hidden.where(id: record)).not_to exist
    end
  end

  describe '.visible' do
    let :record do
      create model, deleted: true, deleted_by: create(:user)
    end

    it 'has a valid factory' do
      expect(record).to be_valid
    end

    it 'does not includes deleted records' do
      expect(described_class.visible.where(id: record)).not_to exist
    end

    it 'includes records that are un-deleted' do
      record.update deleted: false
      expect(described_class.visible.where(id: record)).to exist
    end
  end
end