# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :characters do
      create_list :character, 5
    end

    it 'returns a list of characters' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'characters'

      expect(json[:characters].count).to eq characters.count
    end

    it 'only returns visible characters' do
      characters.sample(3).each(&:delete)

      get :index

      expect(response).to have_http_status :ok
      expect(json[:characters].count).to eq characters.count - 3
    end

    it 'includes deleted characters when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')
      characters.sample(3).each(&:delete)

      get :index, params: session

      expect(response).to have_http_status :ok
      expect(json[:characters].count).to eq characters.count
    end
  end

  describe '#GET show' do
    let :character do
      create :character, creator: active_user
    end

    it 'returns the requested character' do
      get :show, params: { id: character.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'character'
    end

    it 'returns 404 if the character is deleted' do
      character.update deleted: true, deleted_by: active_user

      get :show, params: { id: character.id }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted characters' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.update deleted: true

      get :show, params: { id: character.id }.merge(session)

      expect(response).to have_http_status :ok
    end
  end

  describe '#POST create' do
    it 'requires an authenticated user' do
      expect do
        post :create, params: {
          character: attributes_for(:character)
        }
      end.not_to change { Character.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'creates a character when called by an authenticated user' do
      expect do
        post :create, params: {
          character: attributes_for(:character)
        }.merge(session)
      end.to change { Character.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema 'character'
    end

    it 'prevents banned users from creating characters' do
      active_user.roles << Role.find_by!(name: 'banned')

      expect do
        post :create, params: {
          character: attributes_for(:character)
        }.merge(session)
      end.not_to change { Character.count }

      expect(response).to have_http_status :forbidden
    end

    it 'returns errors if the character is invalid' do
      expect do
        post :create, params: {
          character: attributes_for(:character, name: nil)
        }.merge(session)
      end.not_to change { Character.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :name
    end
  end

  describe '#PATCH update' do
    let :character do
      create :character, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: {
          id: character.id, character: attributes_for(:character)
        }
      end.not_to change { character.reload.attributes }

      expect(response).to have_http_status :unauthorized
    end

    it 'allows the owner to update character attributes' do
      expect do
        patch :update, params: {
          id: character.id, character: attributes_for(:character)
        }.merge(session)
      end.to change { character.reload.attributes }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'character'
    end

    it 'prevents users from updating characters they do not own' do
      character.update user: create(:user)

      expect do
        patch :update, params: {
          id: character.id, character: attributes_for(:character)
        }.merge(session)
      end.not_to change { character.reload.attributes }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to update characters owned by another user' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.update user: create(:user)

      expect do
        patch :update, params: {
          id: character.id, character: attributes_for(:character)
        }.merge(session)
      end.to change { character.reload.attributes }

      expect(response).to have_http_status :ok
    end

    it 'returns errors if the character is invalid' do
      expect do
        patch :update, params: {
          id: character.id, character: attributes_for(:character, name: nil)
        }.merge(session)
      end.not_to change { character.reload.attributes }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :name
    end
  end

  describe '#DELETE destroy' do
    let :character do
      create :character, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: character.id }
      end.not_to change { character.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'allows users to delete a character they own' do
      expect do
        delete :destroy, params: { id: character.id }.merge(session)
      end.to change { character.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end

    it 'prevents users from deleting a character they do no own' do
      character.update user: create(:user)

      expect do
        delete :destroy, params: { id: character.id }.merge(session)
      end.not_to change { character.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to delete characters they do not own' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.update user: create(:user)

      expect do
        delete :destroy, params: { id: character.id }.merge(session)
      end.to change { character.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
