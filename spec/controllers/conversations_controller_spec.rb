require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :conversations do
      create_list :conversation, Faker::Number.between(1, 5), author: create(:user)
    end

    it 'returns a list of conversations' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :meta
      expect(json).to have_key :conversations

      expect(json[:conversations].count).to eq conversations.count
      expect(json[:meta][:total]).to eq conversations.count
    end

    it 'only returns visible conversations' do
      conversations.first.update deleted: true

      get :index, format: :json

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq(conversations.count - 1)
    end

    it 'returns all conversations for admin users' do
      conversations.first.update deleted: true
      active_user.update admin: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq conversations.count
    end
  end

  describe '#POST create' do
    it 'requires an authenticated user' do
      post :create, format: :json

      expect(response.status).to eq 401
      expect(Conversation.count).to eq 0
    end

    it 'creates a new conversation' do
      post :create, format: :json, params: {
        access_token: token.token,
        conversation: {
          posts_attributes: [
            title: Faker::Book.title,
            body: Faker::Hipster.paragraph
          ]
        }
      }

      expect(response.status).to eq 201
      expect(Conversation.count).to eq 1
      expect(Post.count).to eq 1
    end

    it 'does not allow banned users to create conversations' do
      active_user.update banned: true

      post :create, format: :json, params: {
        access_token: token.token,
        conversation: {
          posts_attributes: [
            title: Faker::Book.title,
            body: Faker::Hipster.paragraph
          ]
        }
      }

      expect(response.status).to eq 403
      expect(Conversation.count).to eq 0
    end

    it 'returns errors if the conversation is invalid' do
      post :create, format: :json, params: {
        access_token: token.token,
        conversation: {
          posts_attributes: [
            title: Faker::Book.title,
            body:  nil
          ]
        }
      }

      expect(response.status).to eq 422
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key 'posts.body'

      expect(Conversation.count).to eq 0
      expect(Post.count).to eq 0
    end
  end

  describe '#PATCH update' do
    let! :conversation do
      create :conversation, author: active_user
    end

    it 'requires an authenticated user' do
      patch :update, format: :json, params: {
        id: conversation.id, conversation: { locked: true }
      }

      expect(response.status).to eq 401
      expect(conversation.reload.locked?).to eq false
    end

    it 'only allows admins to mark conversations as locked' do
      patch :update, format: :json, params: {
        access_token: token.token, id: conversation.id, conversation: { locked: true }
      }

      expect(response.status).to eq 200
      expect(conversation.reload.locked?).to eq false
    end

    it 'only allows the author to update a conversation' do
      conversation.update author: create(:user)

      delete :destroy, format: :json, params: {
        access_token: token.token, id: conversation.id
      }

      expect(response.status).to eq 403
      expect(conversation.reload.deleted?).to eq false
    end

    it 'updates the locked state of a conversation' do
      active_user.update admin: true

      patch :update, format: :json, params: {
        access_token: token.token, id: conversation.id, conversation: { locked: true }
      }

      expect(response.status).to eq 200
      expect(json).to have_key :conversation

      expect(conversation.reload.locked?).to eq true
    end
  end

  describe '#DELETE destroy' do
    let :conversation do
      create :conversation, author: active_user
    end

    it 'requires an authenticated user' do
      delete :destroy, format: :json, params: { id: conversation.id }

      expect(response.status).to eq 401
      expect(conversation.reload.deleted?).to eq false
    end

    it 'only allows admins to mark conversations as deleted' do
      delete :destroy, format: :json, params: {
        access_token: token.token, id: conversation.id
      }

      expect(response.status).to eq 403
      expect(conversation.reload.deleted?).to eq false
    end

    it 'marks a conversation as deleted' do
      active_user.update admin: true

      delete :destroy, format: :json, params: {
        access_token: token.token, id: conversation.id
      }

      expect(response.status).to eq 204
      expect(conversation.reload.deleted?).to eq true
    end
  end
end
