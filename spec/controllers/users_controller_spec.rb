require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'GET #index' do
    let :users do
      json[:users]
    end

    let! :user do
      create :user
    end

    let! :deleted_user do
      create :user, deleted: true
    end

    it 'responds with 200' do
      get :index, format: :json
      expect(response.status).to eq 200
    end

    it 'returns only visible users as JSON' do
      get :index, format: :json
      expect(json).to have_key :users
      expect(users.count).to eq 1
      expect(users.first).to have_key :id
      expect(users.first[:id]).to eq user.id
    end

    it %(doesn't return personal fields in the JSON) do
      get :index, format: :json
      expect(users.first).not_to have_key :password_digest
      expect(users.first).not_to have_key :email
      expect(users.first).not_to have_key :email_confirmed_at
      expect(users.first).not_to have_key :first_name
      expect(users.first).not_to have_key :last_name
      expect(users.first).not_to have_key :date_of_birth
    end
  end
end
