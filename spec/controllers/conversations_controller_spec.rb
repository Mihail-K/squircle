require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :conversations do
      create_list :conversation, 5, author: active_user
    end

    it 'returns a list of conversations' do
      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'conversations'
      expect(json[:conversations].count).to eq conversations.count
    end

    it 'only returns visible conversations' do
      deleted_conversations = conversations.sample(3).each do |conversation|
        conversation.update deleted: true, deleted_by: active_user
      end

      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json[:conversations].count).to eq conversations.count - deleted_conversations.count
    end

    it 'returns all conversations for admin users' do
      active_user.update admin: true
      deleted_conversations = conversations.sample(3).each do |conversation|
        conversation.update deleted: true, deleted_by: active_user
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:conversations].count).to eq conversations.count
    end
  end

  describe '#GET show' do
    let :conversation do
      create :conversation
    end

    it 'returns the requested conversation' do
      get :show, format: :json, params: { id: conversation.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'conversation'
    end

    it 'returns 404 for conversations that are deleted' do
      conversation.update deleted: true, deleted_by: active_user

      get :show, format: :json, params: { id: conversation.id }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted conversations' do
      active_user.update admin: true
      conversation.update deleted: true, deleted_by: active_user

      get :show, format: :json, params: { id: conversation.id }.merge(session)

      expect(response).to have_http_status :ok
    end

    it 'returns 404 for conversations in a deleted section' do
      conversation.section.update deleted: true

      get :show, format: :json, params: { id: conversation.id }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    let :section do
      create :section
    end

    it 'requires an authenticated user' do
      expect do
        post :create, format: :json, params: {
          conversation: { section_id: section.id, posts_attributes: [ attributes_for(:post) ] }
        }
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'creates a new conversation' do
      expect do
        post :create, format: :json, params: {
          conversation: { section_id: section.id, posts_attributes: [ attributes_for(:post) ] }
        }.merge(session)
      end.to change { Conversation.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema 'conversation'
    end

    it 'does not allow banned users to create conversations' do
      active_user.update banned: true

      expect do
        post :create, format: :json, params: {
          conversation: { section_id: section.id, posts_attributes: [ attributes_for(:post) ] }
        }.merge(session)
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :forbidden
    end

    it 'returns errors if the conversation is invalid' do
      expect do
        post :create, format: :json, params: {
          conversation: { section_id: section.id, posts_attributes: [ attributes_for(:post, body: nil) ] }
        }.merge(session)
      end.not_to change { Conversation.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key 'posts.body'
    end

    it_behaves_like 'flood_limitable' do
      let :attributes do
        {
          conversation: { section_id: section.id, posts_attributes: [ attributes_for(:post) ] }
        }.merge(session)
      end
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

    it 'returns errors if the conversation is invalid' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: {
          id: conversation.id, conversation: { section_id: nil }
        }.merge(session)
      end.not_to change { conversation.reload.title }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :section
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
