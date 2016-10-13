require 'rails_helper'

RSpec.describe Section, type: :model do
  let :section do
    build :section
  end

  it_behaves_like ApplicationRecord

  it 'has a valid factory' do
    expect(section).to be_valid
  end

  it 'is not valid without a title' do
    section.title = nil
    expect(section).not_to be_valid
  end

  it 'is not valid if the description is too long' do
    section.description = Faker::Lorem.characters(1001)
    expect(section).not_to be_valid
  end

  it 'is not valid without a creator' do
    section.creator = nil
    expect(section).not_to be_valid
  end

  it "queues a job to update posts counts when it's deleted" do
    section = create :section

    expect do
      section.delete
    end.to have_enqueued_job(SectionPostsCountJob).on_queue('low')
  end
end
