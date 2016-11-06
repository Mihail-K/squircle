# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :notifications do
      create_list :notification, 3, user: active_user
    end

    it 'requires an authenticated user' do
      get :index

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of notifications' do
      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :notifications
      expect(json[:notifications].count).to eq 3
    end

    it "doesn't return notifications not owned by the user" do
      notifications.sample.update(user: create(:user))

      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(json[:notifications].count).to eq 2
    end

    it 'marks notifications as read when requested' do
      expect do
        get :index, params: { read: true, access_token: access_token }

        expect(response).to have_http_status :ok
      end.to change { Notification.where(read: true).count }.from(0).to(3)
    end

    context 'pending' do
      it 'returns only undismissed notifications' do
        notifications.sample(2).each do |notification|
          notification.update(dismissed: true)
        end

        get :index, params: { pending: true, access_token: access_token }

        expect(response).to have_http_status :ok
        expect(json[:notifications].count).to eq 1
      end
    end
  end

  describe '#GET show' do
    let :notification do
      create :notification, user: active_user
    end

    it 'requires an authenticated user' do
      get :show, params: { id: notification.id }

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the specified notification' do
      get :show, params: { id: notification.id,
                           access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :notification
    end

    it "doesn't allow users to view notifications they don't own" do
      notification.update(user: create(:user))

      get :show, params: { id: notification.id,
                           access_token: access_token }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#PATCH update' do
    let :notification do
      create :notification, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: { id: notification.id,
                                 notification: { dismissed: true } }

        expect(response).to have_http_status :unauthorized
      end.not_to change { notification.reload.dismissed? }
    end

    it 'dismisses the notification' do
      expect do
        patch :update, params: { id: notification.id,
                                 notification: { dismissed: true },
                                 access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :notification
      end.to change { notification.reload.dismissed? }.from(false).to(true)
    end

    it "doesn't allow users to access notifications they don't own" do
      notification.update(user: create(:user))

      expect do
        patch :update, params: { id: notification.id,
                                 notification: { dismissed: true },
                                 access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { notification.reload.dismissed? }
    end
  end

  describe '#DELETE destroy' do
    let! :notification do
      create :notification, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: notification.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Notification.count }
    end

    it 'deletes the specified notification' do
      expect do
        delete :destroy, params: { id: notification.id,
                                   access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { Notification.count }.by(-1)
    end

    it "doesn't allow the user to delete notifications they don't own" do
      notification.update(user: create(:user))

      expect do
        delete :destroy, params: { id: notification.id,
                                   access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { Notification.count }
    end
  end
end
