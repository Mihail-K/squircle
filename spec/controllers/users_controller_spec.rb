# frozen_string_literal: true
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include_context 'authentication'

  describe 'GET #me' do
    it 'requires an authenticated user' do
      get :me

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the current user' do
      get :me, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :user

      expect(response.body).to include_json(user: { id: active_user.id })
    end
  end

  describe 'GET #index' do
    let! :users do
      [active_user] + create_list(:user, 2)
    end

    it 'responds with 200' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :users
      expect(response.body).to include_json(
        users: users.map { |user| { id: user.id } },
        meta:  { total: users.count }
      )
    end

    it 'returns only visible users' do
      users.sample.soft_delete

      get :index

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        users: users.reject(&:deleted?).map { |user| { id: user.id } },
        meta:  { total: users.count - 1 }
      )
    end

    it 'returns all users when an admin is authenticated' do
      active_user.roles << Role.find_by!(name: 'admin')
      users.sample.soft_delete

      get :index, params: session

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        users: users.map { |user| { id: user.id } },
        meta:  { total: users.count }
      )
    end

    it 'returns a list of recently active users' do
      recently_active = users.sample(2).each do |user|
        user.update_columns(posts_count: 1, last_active_at: Time.current)
      end

      get :index, params: { recently_active: true }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        users: recently_active.sort_by(&:last_active_at).reverse.map { |user| { id: user.id } },
        meta:  { total: recently_active.count }
      )
    end

    it 'returns a list of the most active users' do
      most_active = users.sample(2).each_with_index do |user, index|
        user.update_columns(posts_count: 2 - index)
      end

      get :index, params: { most_active: true }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        users: most_active.sort_by(&:posts_count).reverse.map { |user| { id: user.id } },
        meta:  { total: most_active.count }
      )
    end
  end

  describe '#GET show' do
    let :user do
      create :user
    end

    it 'returns the requested user' do
      get :show, params: { id: user.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :user
      expect(response.body).to include_json(user: { id: user.id })
    end

    it 'returns 404 when the user is deleted' do
      user.update deleted: true, deleted_by: active_user

      get :show, params: { id: user.id }

      expect(response).to have_http_status :not_found
    end

    it "includes the current user's friendship in the serialization" do
      friendship = create :friendship, user: active_user, friend: user

      get :show, params: { id: user.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        user: { friendship: { id: friendship.id } }
      )
    end
  end

  describe '#POST create' do
    it 'creates a new user' do
      expect do
        post :create, params: { user: attributes_for(:user) }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :user
      end.to change { User.count }.by(1)
    end

    it "doesn't allow authenticated users to create new users" do
      expect do
        post :create, params: { user: attributes_for(:user), access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { User.count }
    end

    it 'allows admins to create new users' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: { user: attributes_for(:user), access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :user
      end.to change { User.count }.by(1)
    end

    it 'returns errors when the user is invalid' do
      expect do
        post :create, params: { user: attributes_for(:user, email: nil) }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { email: ["can't be blank"] })
      end.not_to change { User.count }
    end
  end

  describe '#PATCH update' do
    let :user do
      create :user
    end

    let :email do
      Faker::Internet.email
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: { id: active_user.id,
                                 user: { email: email } }

        expect(response).to have_http_status :unauthorized
      end.not_to change { active_user.reload.email }
    end

    it 'updates the user when authenticated' do
      expect do
        patch :update, params: { id: active_user.id,
                                 user: { email: email },
                                 access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :user
        expect(response.body).to include_json(
          user: { id: active_user.id, email: email }
        )
      end.to change { active_user.reload.email }
    end

    it "doesn't allow users to edit other users" do
      expect do
        patch :update, params: { id: user.id,
                                 user: { email: email },
                                 access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { user.reload.email }
    end

    it 'allows admins to edit other users' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: user.id,
                                 user: { email: email },
                                 access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response.body).to include_json(
          user: { id: user.id, email: email }
        )
      end.to change { user.reload.email }.to(email)
    end

    it 'returns errors if the user is invalid' do
      expect do
        patch :update, params: { id: active_user.id,
                                 user: { email: nil },
                                 access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { email: ["can't be blank"] })
      end.not_to change { active_user.reload.email }
    end
  end

  describe '#DELETE destroy' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: user.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { user.reload.deleted? }
    end

    it 'prevents users from deleting other user accounts' do
      expect do
        delete :destroy, params: { id: user.id, access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { user.reload.deleted? }
    end

    it 'marks the authenticated user as deleted' do
      expect do
        delete :destroy, params: { id: active_user.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { active_user.reload.deleted? }.from(false).to(true)
    end

    it 'allows admins to delete any user account' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        delete :destroy, params: { id: user.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { user.reload.deleted? }.from(false).to(true)
    end
  end
end
