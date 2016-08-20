require 'rails_helper'

RSpec.describe BansController, type: :controller do
  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  let :active_user do
    create :user
  end

  let :token do
    create :access_token, resource_owner_id: active_user.id
  end

  describe '#GET index' do
    before :each do
      create_list :ban, Faker::Number.between(1, 5), user: active_user
    end

    it 'requires an authenticated user' do
      get :index, format: :json

      expect(response.status).to eq 401
    end

    it 'returns a list of bans for the user' do
      get :index, format: :json, params: {
        access_token: token.token
      }

      expect(response.status).to eq 200
      expect(json).to have_key :bans
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq active_user.bans.count
    end

    it 'only returns the bans that belong to the user' do
      ban = create :ban
      expect(active_user.bans.count).to eq(Ban.count - 1)

      get :index, format: :json, params: {
        access_token: token.token
      }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq active_user.bans.count
    end

    it 'returns all bans for admin users' do
      create :ban
      active_user.update admin: true

      get :index, format: :json, params: {
        access_token: token.token
      }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq Ban.count
    end
  end

  describe '#POST create' do
    let :user do
      create :user
    end

    before :each do
      active_user.update admin: true
    end

    it 'requires an authenticated user' do
      post :create, format: :json, params: {
        ban: { user_id: user.id, reason: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 401
      expect(user.bans.count).to eq 0
    end

    it 'only allows admin users to create bans' do
      active_user.update admin: false

      post :create, format: :json, params: {
        access_token: token.token, ban: {
          user_id: user.id, reason: Faker::Hipster.paragraph
        }
      }

      expect(response.status).to eq 403
      expect(user.bans.count).to eq 0
    end

    it 'creates a ban for the given user' do
      post :create, format: :json, params: {
        access_token: token.token, ban: {
          user_id: user.id, reason: Faker::Hipster.paragraph
        }
      }

      expect(response.status).to eq 201
      expect(json).to have_key :ban
      expect(user.bans.count).to eq 1
    end
  end
end
