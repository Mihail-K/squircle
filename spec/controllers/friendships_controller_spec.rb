# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FriendshipsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :friendships do
      create_list :friendship, 3
    end

    it 'returns a list of friendships' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :friendships
      expect(json[:friendships].count).to eq 3
    end

    it 'can return friendships for a specific user' do
      friendships.sample.update(user: active_user)

      get :index, params: { user_id: active_user.id }

      expect(response).to have_http_status :ok
      expect(json[:friendships].count).to eq 1
    end
  end

  describe '#GET show' do
    let :friendship do
      create :friendship
    end

    it 'returns the specified friendship' do
      get :show, params: { id: friendship.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :friendship
    end

    it "returns 404 if the friendship doesn't exist" do
      get :show, params: { id: friendship.id + 1 }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    let :friend do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        post :create, params: { friendship: { friend_id: friend.id } }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Friendship.count }
    end

    it 'creates the requested friendship' do
      expect do
        post :create, params: { friendship: { friend_id: friend.id },
                                access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :friendship
      end.to change { Friendship.count }.by(1)
    end

    it 'returns errors if the friendship is invalid' do
      expect do
        post :create, params: { friendship: { friend_id: nil },
                                access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(json[:errors]).to have_key :friend
      end.not_to change { Friendship.count }
    end

    it 'returns 404 if the friend is deleted' do
      friend.soft_delete

      expect do
        post :create, params: { friendship: { friend_id: friend.id },
                                access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { Friendship.count }
    end
  end

  describe '#DELETE destroy' do
    let! :friendship do
      create :friendship, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: friendship.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Friendship.count }
    end

    it 'deletes the specified friendship' do
      expect do
        delete :destroy, params: { id: friendship.id,
                                   access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { Friendship.count }.by(-1)
    end

    it "doesn't allow user to delete friendships they don't own" do
      friendship.update(user: create(:user))

      expect do
        delete :destroy, params: { id: friendship.id,
                                   access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { Friendship.count }
    end
  end
end
