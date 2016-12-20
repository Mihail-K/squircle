# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Visit, type: :model do
  let :visit do
    build :visit
  end

  it 'has a valid factory' do
    expect(visit).to be_valid
  end
end
