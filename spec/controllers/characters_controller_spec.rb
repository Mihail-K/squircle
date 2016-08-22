require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :characters do
      create_list :character, Faker::Number.between(1, 5)
    end

    it 'returns a list of characters' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :characters
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq characters.count
    end

    it 'only returns visible characters' do
      characters.sample.update deleted: true

      get :index, format: :json

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq(characters.count - 1)
    end

    it 'returns all characters for authenticated admins' do
      active_user.update admin: true
      characters.sample.update deleted: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq characters.count
    end

    it 'can return characters only for a specific user' do
      user = characters.sample.user

      get :index, format: :json, params: { user_id: user.id }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq user.characters.count
    end
  end

  describe '#POST create' do
    let :character_attributes do
      {
        name:        Faker::Pokemon.name,
        title:       Faker::Name.title,
        description: Faker::Hipster.paragraph
      }
    end

    it 'requires an authenticated user' do
      old_count = Character.count

      post :create, format: :json, params: {
        character: character_attributes
      }

      expect(response.status).to eq 401
      expect(Character.count).to eq old_count
    end

    it 'creates a character' do
      old_count = Character.count

      post :create, format: :json, params: {
        access_token: token.token, character: character_attributes
      }

      expect(response.status).to eq 201
      expect(json).to have_key :character

      expect(Character.count).to be > old_count
    end

    it %q(doesn't allow banned users to create characters) do
      old_count = Character.count
      active_user.update banned: true

      post :create, format: :json, params: {
        access_token: token.token, character: character_attributes
      }

      expect(response.status).to eq 403
      expect(Character.count).to eq old_count
    end
  end

  describe '#DELETE destroy' do
    let! :character do
      create :character, user: active_user
    end

    it 'requires an authenticated user' do
      delete :destroy, format: :json, params: {
        id: character.id
      }

      expect(response.status).to eq 401
      expect(character.reload.deleted?).to be false
    end

    it 'marks a character as deleted' do
      delete :destroy, format: :json, params: {
        access_token: token.token, id: character.id
      }

      expect(response.status).to eq 204
      expect(character.reload.deleted?).to be true
    end

    it %q(doesn't allow users to delete characters they don't own) do
      character.update user: create(:user)

      delete :destroy, format: :json, params: {
        access_token: token.token, id: character.id
      }

      expect(response.status).to eq 403
      expect(character.reload.deleted?).to be false
    end

    it 'allows admin users to delete any character' do
      active_user.update admin: true
      character.update user: create(:user)

      delete :destroy, format: :json, params: {
        access_token: token.token, id: character.id
      }

      expect(response.status).to eq 204
      expect(character.reload.deleted?).to be true
    end
  end
end
