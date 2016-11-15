# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :characters do
      create_list :character, 3
    end

    it 'returns a list of characters' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :characters
      expect(response.body).to include_json(
        characters: characters.map { |character| { id: character.id } },
        meta:       { total: characters.count }
      )
    end

    it 'only returns visible characters' do
      characters.first.soft_delete

      get :index

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        characters: characters[1..-1].map { |character| { id: character.id } },
        meta:       { total: characters.count - 1 }
      )
    end

    it 'includes deleted characters when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')
      characters.first.soft_delete

      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        characters: characters.map { |character| { id: character.id } },
        meta:       { total: characters.count }
      )
    end
  end

  describe '#GET show' do
    let :character do
      create :character, creator: active_user
    end

    it 'returns the requested character' do
      get :show, params: { id: character.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :character
      expect(response.body).to include_json(character: { id: character.id })
    end

    it 'returns 404 if the character is deleted' do
      character.soft_delete

      get :show, params: { id: character.id }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted characters' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.soft_delete

      get :show, params: { id: character.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response.body).to include_json(
        character: { id: character.id, deleted: true }
      )
    end
  end

  describe '#POST create' do
    it 'requires an authenticated user' do
      expect do
        post :create, params: { character: attributes_for(:character) }

        expect(response).to have_http_status :unauthorized
      end.not_to change { Character.count }
    end

    it 'creates a character when called by an authenticated user' do
      expect do
        post :create, params: { character: attributes_for(:character),
                                access_token: access_token }

        expect(response).to have_http_status :created
        expect(response).to match_response_schema :character
        expect(response.body).to include_json(
          character: { user_id: active_user.id, creator_id: active_user.id }
        )
      end.to change { Character.count }.by(1)
    end

    it 'prevents banned users from creating characters' do
      active_user.roles << Role.find_by!(name: 'banned')

      expect do
        post :create, params: { character: attributes_for(:character),
                                access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { Character.count }
    end

    it 'returns errors if the character is invalid' do
      expect do
        post :create, params: { character: attributes_for(:character, name: nil),
                                access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { name: ["can't be blank"] })
      end.not_to change { Character.count }
    end
  end

  describe '#PATCH update' do
    let :character do
      create :character, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: { id: character.id,
                                 character: attributes_for(:character) }

        expect(response).to have_http_status :unauthorized
      end.not_to change { character.reload.attributes }
    end

    it 'allows the owner to update character attributes' do
      expect do
        patch :update, params: { id: character.id,
                                 character: attributes_for(:character),
                                 access_token: access_token }

        expect(response).to have_http_status :ok
        expect(response).to match_response_schema :character
        expect(response.body).to include_json(character: { id: character.id })
      end.to change { character.reload.attributes }
    end

    it 'prevents users from updating characters they do not own' do
      character.update user: create(:user)

      expect do
        patch :update, params: { id: character.id,
                                 character: attributes_for(:character),
                                 access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { character.reload.attributes }
    end

    it 'allows admins to update characters owned by another user' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.update user: create(:user)

      expect do
        patch :update, params: { id: character.id,
                                 character: attributes_for(:character),
                                 access_token: access_token }

        expect(response).to have_http_status :ok
      end.to change { character.reload.attributes }
    end

    it 'returns errors if the character is invalid' do
      expect do
        patch :update, params: { id: character.id,
                                 character: attributes_for(:character, name: nil),
                                 access_token: access_token }

        expect(response).to have_http_status :unprocessable_entity
        expect(response).to match_response_schema :errors
        expect(response.body).to include_json(errors: { name: ["can't be blank"] })
      end.not_to change { character.reload.attributes }
    end
  end

  describe '#DELETE destroy' do
    let :character do
      create :character, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: character.id }

        expect(response).to have_http_status :unauthorized
      end.not_to change { character.reload.deleted? }
    end

    it 'allows users to delete a character they own' do
      expect do
        delete :destroy, params: { id: character.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { character.reload.deleted? }.from(false).to(true)
    end

    it 'prevents users from deleting a character they do no own' do
      character.update user: create(:user)

      expect do
        delete :destroy, params: { id: character.id, access_token: access_token }

        expect(response).to have_http_status :forbidden
      end.not_to change { character.reload.deleted? }
    end

    it 'allows admins to delete characters they do not own' do
      active_user.roles << Role.find_by!(name: 'admin')
      character.update user: create(:user)

      expect do
        delete :destroy, params: { id: character.id, access_token: access_token }

        expect(response).to have_http_status :no_content
      end.to change { character.reload.deleted? }.from(false).to(true)
    end
  end
end
