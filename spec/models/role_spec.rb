require 'rails_helper'

RSpec.describe Role, type: :model do
  let :role do
    build :role
  end

  it 'has a valid factory' do
    expect(role).to be_valid
  end

  it 'is not valid without a name' do
    role.name = nil
    expect(role).not_to be_valid
  end

  it 'is not valid with a duplicate name' do
    create :role, name: role.name
    expect(role).not_to be_valid
  end

  describe 'user' do
    let :role do
      Role.where name: 'user'
    end

    it 'exists' do
      expect(role).to exist
    end
  end

  describe 'moderator' do
    let :role do
      Role.where name: 'moderator'
    end

    it 'exists' do
      expect(role).to exist
    end
  end

  describe 'admin' do
    let :role do
      Role.where name: 'admin'
    end

    it 'exists' do
      expect(role).to exist
    end
  end

  describe 'banned' do
    let :role do
      Role.where name: 'banned'
    end

    it 'exists' do
      expect(role).to exist
    end
  end
end
