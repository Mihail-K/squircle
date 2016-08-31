require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :conversations do
      create_list :conversation, 3, author: create(:user)
    end

    it 'returns a list of conversations' do
      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json).to have_key :meta
      expect(json).to have_key :conversations

      expect(json[:conversations].count).to eq conversations.count
      expect(json[:meta][:total]).to eq conversations.count
    end

    it 'only returns visible conversations' do
      conversations.sample.update deleted: true

      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json[:meta][:total]).to eq(conversations.count - 1)
    end

    it 'returns all conversations for admin users' do
      conversations.sample.update deleted: true
      active_user.update admin: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response).to have_http_status :ok
      expect(json[:meta][:total]).to eq conversations.count
    end
  end

  describe '#POST create' do
    let :section do
      create :section
    end

    let :conversation_attributes do
      {
        section_id: section.id,
        posts_attributes: [ FactoryGirl.attributes_for(:post).slice(:title, :body) ]
      }
    end

    it 'requires an authenticated user' do
      expect do
        post :create, format: :json, params: { conversation: conversation_attributes }
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'creates a new conversation' do
      expect do
        post :create, format: :json, params: { conversation: conversation_attributes }.merge(session)
      end.to change { Conversation.count }.by(1)

      expect(response).to have_http_status :created
    end

    it 'does not allow banned users to create conversations' do
      active_user.update banned: true

      expect do
        post :create, format: :json, params: { conversation: conversation_attributes }.merge(session)
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :forbidden
    end

    it 'returns errors if the conversation is invalid' do
      conversation_attributes[:posts_attributes].first[:body] = nil

      expect do
        post :create, format: :json, params: { conversation: conversation_attributes }.merge(session)
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key 'posts.body'
    end
  end

  describe '#PATCH update' do
    let! :conversation do
      create :conversation, author: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, format: :json, params: {
          id: conversation.id, conversation: { locked: true }
        }
      end.not_to change { conversation.reload.locked? }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to mark conversations as locked' do
      expect do
        patch :update, format: :json, params: {
          id: conversation.id, conversation: { locked: true }
        }.merge(session)
      end.not_to change { conversation.reload.locked? }

      expect(response).to have_http_status :ok
    end

    it 'updates the locked state of a conversation' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: {
          id: conversation.id, conversation: { locked: true }
        }.merge(session)
      end.to change { conversation.reload.locked? }.from(false).to(true)

      expect(response).to have_http_status :ok
      expect(json).to have_key :conversation
    end
  end

  describe '#DELETE destroy' do
    let :conversation do
      create :conversation, author: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, format: :json, params: { id: conversation.id }
      end.not_to change { conversation.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to mark conversations as deleted' do
      expect do
        delete :destroy, format: :json, params: { id: conversation.id }.merge(session)
      end.not_to change { conversation.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'marks a conversation as deleted when called by an admin user' do
      active_user.update admin: true

      expect do
        delete :destroy, format: :json, params: { id: conversation.id }.merge(session)
      end.to change { conversation.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
