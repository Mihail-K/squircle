require 'rails_helper'

RSpec.describe Conversation, type: :model do
  before :each do
    @conversation = build :conversation
  end

  it 'has a valid factory' do
    expect(@conversation).to be_valid
  end
end
