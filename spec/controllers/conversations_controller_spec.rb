require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
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
    let! :conversations do
      create_list :conversation, Faker::Number.between(1, 5)
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
  end
end
