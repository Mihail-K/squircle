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

      expect(json[:user][:id]).to eq active_user.id
    end
  end

  describe 'GET #index' do
    let! :users do
      create_list(:user, 4) + [active_user]
    end

    it 'responds with 200' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :users
    end

    it 'returns only visible users' do
      users.sample.update deleted: true, deleted_by: active_user

      get :index

      expect(response).to have_http_status :ok
      expect(json[:users].count).to eq users.count - 1
    end

    it 'returns all users when an admin is authenticated' do
      active_user.roles << Role.find_by!(name: 'admin')
      users.sample.update deleted: true, deleted_by: active_user

      get :index, params: session

      expect(response).to have_http_status :ok
      expect(json[:users].count).to eq users.count
    end

    it 'returns a list of recently active users' do
      recently_active = users.sample(3).each do |user|
        create :post, author: user
      end

      get :index, params: { recently_active: true }

      expect(response).to have_http_status :ok
      expect(json[:users].count).to eq recently_active.count
      expect(json[:users].map { |user| user[:id] }).to contain_exactly(*recently_active.map(&:id))
    end

    it 'returns a list of the most active users' do
      most_active = users.sample(3).each_with_index do |user, index|
        create_list :post, 3 - index, author: user
      end

      get :index, params: { most_active: true }

      expect(response).to have_http_status :ok
      expect(json[:users].count).to eq most_active.count
      expect(json[:users].map { |user| user[:id] }).to eq most_active.map(&:id)
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
    end

    it 'returns 404 when the user is deleted' do
      user.update deleted: true, deleted_by: active_user

      get :show, params: { id: user.id }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    it 'creates a new user' do
      expect do
        post :create, params: { user: attributes_for(:user) }
      end.to change { User.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema :user
    end

    it "doesn't allow authenticated users to create new users" do
      expect do
        post :create, params: { user: attributes_for(:user) }.merge(session)
      end.not_to change { User.count }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to create new users' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: { user: attributes_for(:user) }.merge(session)
      end.to change { User.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema :user
    end

    it 'returns errors when the user is invalid' do
      expect do
        post :create, params: { user: attributes_for(:user, email: nil) }
      end.not_to change { User.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema :errors

      expect(json[:errors]).to have_key :email
    end
  end

  describe '#PATCH update' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: {
          id: active_user.id, user: { email: Faker::Internet.email }
        }
      end.not_to change { active_user.reload.email }

      expect(response).to have_http_status :unauthorized
    end

    it 'updates the user when authenticated' do
      expect do
        patch :update, params: {
          id: active_user.id, user: { email: Faker::Internet.email }
        }.merge(session)
      end.to change { active_user.reload.email }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :user
    end

    it "doesn't allow users to edit other users" do
      expect do
        patch :update, params: {
          id: user.id, user: { email: Faker::Internet.email }
        }.merge(session)
      end.not_to change { user.reload.email }

      expect(response).to have_http_status :forbidden
    end

    it 'returns errors if the user is invalid' do
      expect do
        patch :update, params: { id: active_user.id, user: { email: nil } }.merge(session)
      end.not_to change { active_user.reload.email }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema :errors

      expect(json[:errors]).to have_key :email
    end
  end

  describe '#DELETE destroy' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: user.id }
      end.not_to change { user.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'prevents users from deleting other user accounts' do
      expect do
        delete :destroy, params: { id: user.id }.merge(session)
      end.not_to change { user.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'marks the authenticated user as deleted' do
      expect do
        delete :destroy, params: { id: active_user.id }.merge(session)
      end.to change { active_user.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end

    it 'allows admins to delete any user account' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        delete :destroy, params: { id: user.id }.merge(session)
      end.to change { user.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
