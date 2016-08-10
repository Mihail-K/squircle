require 'rails_helper'

RSpec.describe Post, type: :model do
  before :each do
    @post = build :post
  end

  it 'has a valid factory' do
    expect(@post).to be_valid
  end
end
