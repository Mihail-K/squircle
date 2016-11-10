# frozen_string_literal: true
require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :likes do
      create_list :like, 3
    end

    it 'returns a list of likes' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :likes
    end
  end

  describe '#GET show' do
    let :like do
      create :like
    end

    it 'returns the specified like' do
      get :show, params: { id: like.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :like
    end
  end

  describe '#POST create' do
    let :likeable do
      create :post
    end

    it 'requires an authenticated user' do
      expect do
        post :create, params: { like: { likeable_id: likeable.id, likeable_type: 'Post' } }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Like.count }
    end

    it 'creates a like on the post' do
      expect do
        post :create, params: { like: { likeable_id: likeable.id, likeable_type: 'Post' },
                                access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :like
      end.to change { Like.count }.by(1)
    end

    it "returns 404 if the user doesn't have access to the likeable object" do
      likeable.soft_delete

      expect do
        post :create, params: { like: { likeable_id: likeable.id, likeable_type: 'Post' },
                                access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { Like.count }
    end

    it "returns 404 if the likeable type isn't allowed" do
      likeable = create :ban, user: active_user

      expect do
        post :create, params: { like: { likeable_id: likeable.id, likeable_type: 'Ban' },
                                access_token: access_token }

        expect(response).to have_http_status :not_found
      end.not_to change { Like.count }
    end
  end

  describe '#DELETE destroy' do
    let! :like do
      create :like, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: like.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Like.count }
    end

    it 'deletes the like' do
      expect do
        delete :destroy, params: { id: like.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { Like.count }.by(-1)
    end

    it "doesn't allow the user to delete likes they don't own" do
      like.update user: create(:user)

      expect do
        delete :destroy, params: { id: like.id, access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { Like.count }
    end
  end
end
