# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BansController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :bans do
      create_list :ban, 3, user: active_user
    end

    it 'requires an authenticated user' do
      get :index

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of bans for the user' do
      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :bans
      expect(response.body).to include_json(
        bans: bans.map { |ban| { id: ban.id } },
        meta: { total: bans.count }
      )
    end

    it 'only returns the bans that belong to the user' do
      bans.first.update user: create(:user)

      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        bans: bans[1..-1].map { |ban| { id: ban.id } },
        meta: { total: bans.count - 1 }
      )
    end

    it 'returns all bans for admin users' do
      active_user.roles << Role.find_by!(name: 'admin')
      bans.first.update user: create(:user)

      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        bans: bans.map { |ban| { id: ban.id } },
        meta: { total: bans.count }
      )
    end
  end

  describe '#GET show' do
    let :ban do
      create :ban, user: active_user
    end

    it 'requires an authenticated user' do
      get :show, params: { id: ban.id }

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the requested ban, if it belongs to the current user' do
      get :show, params: { id: ban.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :ban
      expect(response.body).to include_json(ban: { id: ban.id })
    end

    it 'prevents users from accessing bans that do not belong to them' do
      ban.update user: create(:user)

      get :show, params: { id: ban.id, access_token: access_token }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view bans that belong to other users' do
      active_user.roles << Role.find_by!(name: 'admin')
      ban.update user: create(:user)

      get :show, params: { id: ban.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(ban: { id: ban.id })
    end

    it 'returns 404 if the ban has been deleted' do
      ban.soft_delete

      get :show, params: { id: ban.id, access_token: access_token }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        post :create, params: { ban: attributes_for(:ban, user_id: user.id) }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Ban.count }
    end

    it 'only allows admin users to create bans' do
      expect do
        post :create, params: { ban: attributes_for(:ban, user_id: user.id),
                                access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { Ban.count }
    end

    it 'creates a ban for the given user when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: { ban: attributes_for(:ban, user_id: user.id),
                                access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :ban
        expect(response.body).to include_json(
          ban: { user_id: user.id, creator_id: active_user.id }
        )
      end.to change { Ban.count }.by(1)
    end

    it 'returns errors if the ban is invalid' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: { ban: attributes_for(:ban, user_id: user.id, reason: nil),
                                access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { reason: ["can't be blank"] })
      end.not_to change { Ban.count }
    end
  end

  describe '#PATCH update' do
    let :ban do
      create :ban
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: { id: ban.id, ban: attributes_for(:ban) }

        expect(response).to have_http_status :unauthorized
      end.not_to change { ban.reload.attributes }
    end

    it 'only allows admins to update bans' do
      ban.update user: active_user

      expect do
        patch :update, params: { id: ban.id, ban: attributes_for(:ban), access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { ban.reload.attributes }
    end

    it 'updates the reason on a ban when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: ban.id, ban: attributes_for(:ban), access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :ban
        expect(response.body).to include_json(ban: { id: ban.id })
      end.to change { ban.reload.attributes }
    end

    it 'updates the deleted state on a ban' do
      ban.soft_delete
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: ban.id, ban: { deleted: false }, access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response.body).to include_json(ban: { id: ban.id, deleted: false })
      end.to change { ban.reload.deleted? }.from(true).to(false)
    end

    it 'returns errors if the ban is invalid' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: ban.id, ban: { reason: nil }, access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { reason: ["can't be blank"] })
      end.not_to change { ban.reload.attributes }
    end
  end

  describe '#DELETE destroy' do
    let :ban do
      create :ban
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: ban.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { ban.reload.deleted? }
    end

    it 'only allows admins to delete bans' do
      ban.update user: active_user

      expect do
        delete :destroy, params: { id: ban.id, access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { ban.reload.deleted? }
    end

    it 'marks a ban as deleted when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        delete :destroy, params: { id: ban.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { ban.reload.deleted? }.from(false).to(true)
    end
  end
end
