# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UserBucketJob, type: :job do
  let! :user do
    create :user
  end

  it 'marks users as inactive' do
    user.update(last_active_at: 45.days.ago)

    expect do
      UserBucketJob.perform_now
    end.to change { user.reload.bucket }.from('active').to('inactive')
  end

  it "doesn't mark recently active users as inactive" do
    user.update(last_active_at: 15.days.ago)

    expect do
      UserBucketJob.perform_now
    end.not_to change { user.reload.bucket }
  end

  it 'marks recently active users as active' do
    user.update(last_active_at: 15.days.ago, bucket: 'inactive')

    expect do
      UserBucketJob.perform_now
    end.to change { user.reload.bucket }.from('inactive').to('active')
  end

  it "doesn't mark inactive users as active" do
    user.update(last_active_at: 45.days.ago, bucket: 'inactive')

    expect do
      UserBucketJob.perform_now
    end.not_to change { user.reload.bucket }
  end

  it "marks users that haven't been active for a long time as lost" do
    user.update(last_active_at: 6.months.ago)

    expect do
      UserBucketJob.perform_now
    end.to change { user.reload.bucket }.from('active').to('lost')
  end
end
