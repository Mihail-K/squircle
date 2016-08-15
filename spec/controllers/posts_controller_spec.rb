require 'rails_helper'

RSpec.describe PostsController, type: :controller do
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
    let! :posts do
      create_list :post, Faker::Number.between(1, 5)
    end

    it 'returns a list of posts' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :posts
      expect(json).to have_key :meta

      expect(json[:meta][:page]).to eq 1
      expect(json[:meta][:count]).to eq 10
      expect(json[:meta][:total]).to eq posts.length
    end

    it 'returns a list of only visible posts' do
      # Mark some number of posts as deleted.
      post_ids  = posts.select { Faker::Boolean.boolean }.map(&:id)
      post_ids += posts.first(3).map(&:id) if post_ids.empty?
      Post.where(id: post_ids).update_all deleted: true

      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to be < posts.length
    end

    it 'returns all posts for authenticated admins' do
      # Mark all of the posts as deleted.
      Post.where(id: posts.map(&:id)).update_all deleted: true
      active_user.update admin: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq posts.count
    end

    it 'accepts an author_id as a parameter' do
      author = posts.sample.author

      get :index, format: :json, params: { author_id: author.id }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq author.posts_count
    end

    it 'accepts a conversation_id as a parameter' do
      conversation = posts.sample.conversation

      get :index, format: :json, params: { conversation_id: conversation.id }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq conversation.posts_count
    end
  end

  describe '#POST create' do
    let! :conversation do
      create :conversation
    end

    let :post_body do
      build(:post, conversation: conversation).as_json(
        only: %i(conversation_id title body)
      )
    end

    it 'creates a new post on a conversation' do
      posts_count = conversation.posts.count

      post :create, format: :json, params: { access_token: token.token, post: post_body }

      expect(response.status).to eq 201
      expect(json).to have_key :post

      expect(conversation.posts.count).to be > posts_count
    end

    it 'requires an authenticated user' do
      post :create, format: :json, params: { post: post_body }

      expect(response.status).to eq 401
    end

    it 'does not allow banned users to create posts' do
      active_user.update banned: true

      post :create, format: :json, params: { access_token: token.token, post: post_body }

      expect(response.status).to eq 403
    end

    it 'does not allow posting in conversations that do not exist' do
      post :create, format: :json, params: {
        access_token: token.token, post: post_body.merge(conversation_id: 1000)
      }

      expect(response.status).to eq 422
    end

    it 'does not allow posting in locked conversations' do
      conversation.update locked: true, locked_by: create(:user, admin: true)

      post :create, format: :json, params: { access_token: token.token, post: post_body }

      expect(response.status).to eq 403
    end
  end

  describe '#PATCH update' do
    let! :post do
      create :post, author: active_user
    end

    it 'updates the body of a post' do
      old_body = post.body
      patch :update, format: :json, params: {
        access_token: token.token, id: post.id, post: { body: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 200
      expect(json).to have_key :post

      expect(post.reload.body).not_to eq old_body
    end

    it 'sets the editor when a post is modified' do
      expect(post.editor).to be nil
      patch :update, format: :json, params: {
        access_token: token.token, id: post.id, post: { body: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 200
      expect(post.reload.editor).to eq active_user
    end

    it 'requires an authenticated user' do
      old_body = post.body
      patch :update, format: :json, params: {
        id: post.id, post: { body: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 401
      expect(post.reload.editor).to be nil
      expect(post.body).to eq old_body
    end

    it %(does not allow user's to edit other user's posts) do
      old_body = post.body
      post.update author: build(:user)
      patch :update, format: :json, params: {
        access_token: token.token, id: post.id, post: { body: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 403
      expect(post.reload.editor).to be nil
      expect(post.body).to eq old_body
    end

    it %(it allows admin users to edit other user's posts) do
      old_body = post.body
      active_user.update admin: true
      post.update author: build(:user)
      patch :update, format: :json, params: {
        access_token: token.token, id: post.id, post: { body: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 200
      expect(post.reload.editor).to eq active_user
      expect(post.body).not_to eq old_body
    end
  end

  describe '#DELETE destroy' do
    let! :post do
      create :post, author: active_user
    end

    it 'marks a post as deleted' do
      delete :destroy, format: :json, params: {
        access_token: token.token, id: post.id
      }

      expect(response.status).to eq 204
      expect(post.reload.deleted?).to be true
    end

    it 'requires an authenticated user' do
      delete :destroy, format: :json, params: { id: post.id }

      expect(response.status).to eq 401
      expect(post.reload.deleted?).to be false
    end

    it %(does not allow users to delete other user's posts) do
      post.update author: build(:user)
      delete :destroy, format: :json, params: {
        access_token: token.token, id: post.id
      }

      expect(response.status).to eq 403
      expect(post.reload.deleted?).to be false
    end

    it %(allows admin users to delete other user's posts) do
      post.update author: build(:user)
      active_user.update admin: true
      delete :destroy, format: :json, params: {
        access_token: token.token, id: post.id
      }

      expect(response.status).to eq 204
      expect(post.reload.deleted?).to be true
    end
  end
end
