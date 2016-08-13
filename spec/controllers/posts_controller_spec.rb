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
      create_list :post, Faker::Number.between(5, 15)
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
      post_ids += posts.first(3).id if post_ids.empty?
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

    it 'requires an authenticated user' do
      post :create, format: :post, params: { post: post_body }

      expect(response.status).to eq 401
    end

    it 'creates a new post on a conversation' do
      posts_count = conversation.posts.count

      post :create, format: :post, params: { access_token: token.token, post: post_body }

      expect(response.status).to eq 201
      expect(json).to have_key :post

      expect(conversation.posts.count).to be > posts_count
    end
  end
end
