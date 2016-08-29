require 'rails_helper'

RSpec.describe Section, type: :model do
  let :section do
    build :section
  end

  it 'has a valid factory' do
    expect(section).to be_valid
  end
end
