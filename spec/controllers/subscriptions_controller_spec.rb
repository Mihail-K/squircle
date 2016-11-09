# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :subscriptions do
      create_list :subscription, 3
    end

    it 'requires an authenticated user' do
      get :index

      expect(response).to have_http_status :unauthorized
    end

    it "doesn't return subscriptions not owned by the user" do
      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :subscriptions
      expect(json[:subscriptions]).to be_empty
    end

    it 'returns a list of subscriptions owned by the user' do
      subscriptions.each { |subscription| subscription.update(user: active_user) }

      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :subscriptions
      expect(json[:subscriptions]).not_to be_empty
    end
  end

  describe '#GET show' do
    let :subscription do
      create :subscription
    end

    it 'requires an authenticated user' do
      get :show, params: { id: subscription.id }

      expect(response).to have_http_status :unauthorized
    end

    it "doesn't return subscriptions not owned by the user" do
      get :show, params: { id: subscription.id, access_token: access_token }

      expect(response).to have_http_status :not_found
    end

    it 'returns a list of subscriptions owned by the user' do
      subscription.update(user: active_user)

      get :show, params: { id: subscription.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :subscription
    end
  end

  describe '#POST create' do
    let :conversation do
      create :conversation
    end

    it 'requires an authenticated user' do
      expect do
        post :create, params: { subscription: { conversation_id: conversation.id } }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Subscription.count }
    end

    it 'creates a subscription to a conversation' do
      expect do
        post :create, params: { subscription: { conversation_id: conversation.id },
                                access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :subscription
      end.to change { Subscription.count }.by(1)
    end

    it "doesn't create subscriptions for conversations the user cannot see" do
      conversation.soft_delete

      expect do
        post :create, params: { subscription: { conversation_id: conversation.id },
                                access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { Subscription.count }
    end

    it 'returns errors if the subscription is invalid' do
      expect do
        post :create, params: { subscription: { conversation_id: nil },
                                access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(json[:errors]).to have_key :conversation
      end.not_to change { Subscription.count }
    end
  end
end
