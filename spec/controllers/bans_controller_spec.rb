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
    let! :bans do
      create_list :ban, Faker::Number.between(1, 3), user: active_user
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

      expect(json[:meta][:total]).to eq bans.count
    end

    it 'only returns the bans that belong to the user' do
      ban = create :ban
      expect(bans.count).to eq(Ban.count - 1)

      get :index, format: :json, params: {
        access_token: token.token
      }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq bans.count
    end

    it 'returns all bans for admin users' do
      create :ban
      active_user.update admin: true

      get :index, format: :json, params: {
        access_token: token.token
      }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq(bans.count + 1)
    end

    it 'returns only the bans for a specific user' do
      user = create :user, :with_bans
      active_user.update admin: true

      get :index, format: :json, params: {
        access_token: token.token, user_id: user.id
      }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq user.bans.count
    end
  end

  describe '#GET show' do
    let! :bans do
      create_list :ban, Faker::Number.between(1, 3), user: active_user
    end

    it 'requires an authenticated user' do
      get :show, format: :json, params: { id: bans.sample.id }

      expect(response.status).to eq 401
    end

    it %q(returns a ban that's owned by the user) do
      get :show, format: :json, params: { access_token: token.token, id: bans.sample.id }

      expect(response.status).to eq 200
      expect(json).to have_key :ban

      expect(json[:ban]).not_to have_key :creator_id
      expect(json[:ban]).not_to have_key :creator
    end

    it %q(doesn't return bans owned by a different user) do
      ban = create :ban

      get :show, format: :json, params: { access_token: token.token, id: ban.id }

      expect(response.status).to eq 404
    end

    it 'allows admins to see all bans' do
      ban = create :ban
      active_user.update admin: true

      get :show, format: :json, params: { access_token: token.token, id: ban.id }

      expect(response.status).to eq 200
      expect(json).to have_key :ban

      expect(json[:ban]).to have_key :creator_id
      expect(json[:ban]).to have_key :creator
    end

    it %q(returns 404 if the ban doesn't exist) do
      active_user.update admin: true

      get :show, format: :json, params: { access_token: token.token, id: Ban.count + 1 }

      expect(response.status).to eq 404
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

  describe '#PATCH update' do
    let! :ban do
      create :ban
    end

    it 'requires an authenticated user' do
      old_reason = ban.reason

      patch :update, format: :json, params: {
        id: ban.id, ban: { reason: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 401
      expect(ban.reload.reason).to eq old_reason
    end

    it 'only allows admins to delete bans' do
      old_reason = ban.reason

      patch :update, format: :json, params: {
        access_token: token.token, id: ban.id, ban: { reason: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 404
      expect(ban.reload.reason).to eq old_reason
    end

    it 'updates the reason on a ban' do
      old_reason = ban.reason
      active_user.update admin: true

      patch :update, format: :json, params: {
        access_token: token.token, id: ban.id, ban: { reason: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 200
      expect(ban.reload.reason).not_to eq old_reason
    end

    it 'updates the deleted state on a ban' do
      ban.update deleted: true
      active_user.update admin: true

      patch :update, format: :json, params: {
        access_token: token.token, id: ban.id, ban: { deleted: false }
      }

      expect(response.status).to eq 200
      expect(ban.reload.deleted?).to be false
    end
  end

  describe '#DELETE destroy' do
    let! :ban do
      create :ban
    end

    it 'requires an authenticated user' do
      delete :destroy, format: :json, params: {
        id: ban.id
      }

      expect(response.status).to eq 401
      expect(ban.reload.deleted?).to be false
    end

    it 'only allows admins to delete bans' do
      delete :destroy, format: :json, params: {
        access_token: token.token, id: ban.id
      }

      expect(response.status).to eq 404
      expect(ban.reload.deleted?).to be false
    end

    it 'marks a ban as deleted' do
      active_user.update admin: true

      delete :destroy, format: :json, params: {
        access_token: token.token, id: ban.id
      }

      expect(response.status).to eq 204
      expect(ban.reload.deleted?).to be true
    end
  end
end
