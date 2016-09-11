require 'rails_helper'

RSpec.describe Permission, type: :model do
  let :permission do
    build :permission
  end

  it 'has a valid factory' do
    expect(permission).to be_valid
  end

  it 'is not valid without a name' do
    permission.name = nil
    expect(permission).not_to be_valid
  end

  it 'is not valid with a duplicate name' do
    create :permission, name: permission.name
    expect(permission).not_to be_valid
  end
end
