# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PostNotificationJob, type: :job do
  let! :post do
    create :post
  end

  context 'without subscribers' do
    it "doesn't create a notification" do
      expect do
        PostNotificationJob.perform_now(post.id)
      end.not_to change { Notification.count }
    end
  end

  context 'with subscribers to the conversation' do
    let! :subscription do
      create :subscription, conversation: post.conversation
    end

    it 'creates a new notification' do
      expect do
        PostNotificationJob.perform_now(post.id)
      end.to change { Notification.count }.by(1)
    end

    it "doesn't create a notification if one already exists" do
      create :notification, user: subscription.user, targetable: post

      expect do
        PostNotificationJob.perform_now(post.id)
      end.not_to change { Notification.count }
    end
  end
end
