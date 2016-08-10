require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'GET #index' do
    let :users do
      json[:users]
    end

    before :each do
      @user = create :user
      @deleted_user = create :user, deleted: true
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
      expect(users.first[:id]).to eq @user.id
    end

    it %(doesn't return personal fields in the JSON) do
      get :index, format: :json

      user = users.first
      expect(user).not_to have_key :password_digest

      expect(user).not_to have_key :email
      expect(user).not_to have_key :email_confirmed_at

      expect(user).not_to have_key :first_name
      expect(user).not_to have_key :last_name
      expect(user).not_to have_key :date_of_birth
    end
  end
end
