require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'GET #me' do
    it 'requires an authenticated user' do
      get :me, format: :json

      expect(response.status).to eq 401
    end

    it 'returns the current user' do
      get :me, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json).to have_key :user

      expect(json[:user][:id]).to eq active_user.id
    end
  end

  describe 'GET #index' do
    let :users do
      json[:users]
    end

    let! :deleted_user do
      create :user, deleted: true
    end

    it 'responds with 200' do
      get :index, format: :json

      expect(response.status).to eq 200
    end

    it 'returns only visible users' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :users
      expect(users.count).to eq 1
      expect(users.first).to have_key :id
      expect(users.first[:id]).to eq active_user.id
    end

    it 'returns all visible for authenticated admins' do
      active_user.update admin: true
      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(users.count).to eq 2
      expect(users.map { |user| user[:id] }).to contain_exactly active_user.id, deleted_user.id
    end

    it %(doesn't return personal fields in the JSON) do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(users.count).to eq 1
      users.each do |user|
        %i(password_digest email email_confirmed_at first_name last_name date_of_birth).each do |field|
          expect(user).not_to have_key field
        end
      end
    end

    it 'returns personal fields for the authenticated user only' do
      create :user # Create a second user (which is not authenticated)
      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(users.count).to eq 2
      users.each do |user|
        expect(user).not_to have_key :password_digest
        %i(email email_confirmed_at first_name last_name date_of_birth).each do |field|
          expect(user.key?(field)).to eq(user[:id] == active_user.id)
        end
      end
    end

    it 'always returns personal fields for authenticated administrators' do
      active_user.update admin: true
      create :user # Create a second user (which is not authenticated)
      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(users.count).to eq 3
      users.each do |user|
        expect(user).not_to have_key :password_digest
        %i(email email_confirmed_at first_name last_name date_of_birth).each do |field|
          expect(user).to have_key field
        end
      end
    end
  end

  describe '#POST create' do
    let :user_attributes do
      {
        email: Faker::Internet.email,
        date_of_birth: Faker::Date.between(50.years.ago, 13.years.ago),

        display_name: Faker::Internet.user_name,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,

        password: '12345678',
        password_confirmation: '12345678'
      }
    end

    it 'creates a new user' do
      old_count = User.count

      post :create, format: :json, params: { user: user_attributes }

      expect(response.status).to eq 201
      expect(json).to have_key :user

      expect(User.count).to be > old_count
    end

    it %q(doesn't allow authenticated users to create new users) do
      old_count = User.count

      post :create, format: :json, params: {
        access_token: token.token, user: user_attributes
      }

      expect(response.status).to eq 403
      expect(User.count).to eq old_count
    end

    it 'returns errors when the user is invalid' do
      old_count = User.count

      post :create, format: :json, params: { user: user_attributes.merge(email: nil) }

      expect(response.status).to eq 422
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key :email

      expect(User.count).to eq old_count
    end
  end
end
