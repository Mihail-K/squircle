require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  let! :deleted_user do
    create :user, deleted: true
  end

  describe 'GET #index' do
    let :users do
      json[:users]
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
end
