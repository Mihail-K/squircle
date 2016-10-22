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
end
