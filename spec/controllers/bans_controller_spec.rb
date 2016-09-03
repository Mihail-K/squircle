require 'rails_helper'

RSpec.describe BansController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :bans do
      create_list :ban, 5, user: active_user
    end

    it 'requires an authenticated user' do
      get :index, format: :json

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of bans for the user' do
      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'bans'

      expect(json[:bans].count).to eq bans.count
    end

    it 'only returns the bans that belong to the user' do
      bans.sample(3).each do |ban|
        ban.update user: create(:user)
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:bans].count).to eq bans.count - 3
    end

    it 'returns all bans for admin users' do
      active_user.update admin: true
      bans.sample(3).each do |ban|
        ban.update user: create(:user)
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:bans].count).to eq bans.count
    end
  end

  describe '#GET show' do
    let :ban do
      create :ban, user: active_user
    end

    it 'requires an authenticated user' do
      get :show, format: :json, params: { id: ban.id }

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the requested ban, if it belongs to the current user' do
      get :show, format: :json, params: { id: ban.id }.merge(session)

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'ban'
    end

    it 'prevents users from accessing bans that do not belong to them' do
      ban.update user: create(:user)

      get :show, format: :json, params: { id: ban.id }.merge(session)

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view bans that belong to other users' do
      active_user.update admin: true
      ban.update user: create(:user)

      get :show, format: :json, params: { id: ban.id }.merge(session)

      expect(response).to have_http_status :ok
    end

    it 'returns 404 if the ban has been deleted' do
      ban.update deleted: true

      get :show, format: :json, params: { id: ban.id }.merge(session)

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        post :create, format: :json, params: {
          ban: attributes_for(:ban, user_id: user.id)
        }
      end.not_to change { Ban.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admin users to create bans' do
      expect do
        post :create, format: :json, params: {
          ban: attributes_for(:ban, user_id: user.id)
        }.merge(session)
      end.not_to change { Ban.count }

      expect(response).to have_http_status :forbidden
    end

    it 'creates a ban for the given user when called by an admin' do
      active_user.update admin: true

      expect do
        post :create, format: :json, params: {
          ban: attributes_for(:ban, user_id: user.id)
        }.merge(session)
      end.to change { Ban.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema 'ban'
    end

    it 'returns errors if the ban is invalid' do
      active_user.update admin: true

      expect do
        post :create, format: :json, params: {
          ban: attributes_for(:ban, user_id: user.id, reason: nil)
        }.merge(session)
      end.not_to change { Ban.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :reason
    end
  end

  describe '#PATCH update' do
    let :ban do
      create :ban, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, format: :json, params: { id: ban.id, ban: attributes_for(:ban) }
      end.not_to change { ban.reload.attributes }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to delete bans' do
      expect do
        patch :update, format: :json, params: { id: ban.id, ban: attributes_for(:ban) }.merge(session)
      end.not_to change { ban.reload.attributes }

      expect(response).to have_http_status :forbidden
    end

    it 'updates the reason on a ban when called by an admin' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: { id: ban.id, ban: attributes_for(:ban) }.merge(session)
      end.to change { ban.reload.attributes }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'ban'
    end

    it 'updates the deleted state on a ban' do
      ban.update deleted: true
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: { id: ban.id, ban: { deleted: false } }.merge(session)
      end.to change { ban.reload.deleted? }.from(true).to(false)

      expect(response).to have_http_status :ok
    end

    it 'prevents the assigned user from being changed' do
      active_user.update admin: true
      user_id = create(:user).id

      expect do
        patch :update, format: :json, params: { id: ban.id, ban: { user_id: user_id } }.merge(session)
      end.not_to change { ban.reload.user }

      expect(response).to have_http_status :ok
    end

    it 'prevents the assigned creator from being changed' do
      active_user.update admin: true
      user_id = create(:user).id

      expect do
        patch :update, format: :json, params: { id: ban.id, ban: { creator_id: user_id } }.merge(session)
      end.not_to change { ban.reload.creator }

      expect(response).to have_http_status :ok
    end

    it 'returns errors if the ban is invalid' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: { id: ban.id, ban: { reason: nil } }.merge(session)
      end.not_to change { ban.reload.attributes }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :reason
    end
  end

  describe '#DELETE destroy' do
    let :ban do
      create :ban, user: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, format: :json, params: { id: ban.id }
      end.not_to change { ban.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to delete bans' do
      expect do
        delete :destroy, format: :json, params: { id: ban.id }.merge(session)
      end.not_to change { ban.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'marks a ban as deleted when called by an admin' do
      active_user.update admin: true

      expect do
        delete :destroy, format: :json, params: { id: ban.id }.merge(session)
      end.to change { ban.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
