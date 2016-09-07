require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :posts do
      create_list :post, 5
    end

    it 'returns a list of posts' do
      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'posts'

      expect(json[:posts].count).to eq posts.count
    end

    it 'returns only visible posts' do
      deleted_posts = posts.sample(3).each do |post|
        post.update deleted: true, deleted_by: active_user
      end

      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json[:posts].count).to eq posts.count - deleted_posts.count
    end

    it 'includes deleted posts when called by an admin' do
      active_user.update admin: true
      posts.sample(3).each do |post|
        post.update deleted: true, deleted_by: active_user
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:posts].count).to eq posts.count
    end
  end

  describe '#GET show' do
    let :post do
      create :post
    end

    it 'returns the requested post' do
      get :show, format: :json, params: { id: post.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'post'
    end

    it 'returns 404 for posts that are deleted' do
      post.update deleted: true, deleted_by: active_user

      get :show, format: :json, params: { id: post.id }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted posts' do
      post.update deleted: true, deleted_by: active_user
      active_user.update admin: true

      get :show, format: :json, params: { id: post.id }.merge(session)

      expect(response).to have_http_status :ok
    end

    it 'returns 404 for posts in a deleted conversation' do
      post.conversation.update deleted: true

      get :show, format: :json, params: { id: post.id }

      expect(response).to have_http_status :not_found
    end

    it 'returns 404 for posts in a deleted section' do
      post.conversation.section.update deleted: true

      get :show, format: :json, params: { id: post.id }

      expect(response).to have_http_status :not_found
    end
  end

  describe '#POST create' do
    let! :conversation do
      create :conversation
    end

    it 'requires an authenticated user' do
      expect do
        post :create, format: :json, params: {
          post: attributes_for(:post, conversation_id: conversation.id)
        }
      end.not_to change { Post.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'creates a new post in a conversation' do
      expect do
        post :create, format: :json, params: {
          post: attributes_for(:post, conversation_id: conversation.id)
        }.merge(session)
      end.to change { Post.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema :post
    end

    it 'does not allow banned users to create posts' do
      active_user.update banned: true

      expect do
        post :create, format: :json, params: {
          post: attributes_for(:post, conversation_id: conversation.id)
        }.merge(session)
      end.not_to change { Post.count }

      expect(response).to have_http_status :forbidden
    end

    it 'does not allow posting in deleted conversations' do
      conversation.update deleted: true

      expect do
        post :create, format: :json, params: {
          post: attributes_for(:post, conversation_id: conversation.id)
        }.merge(session)
      end.not_to change { Post.count }

      expect(response).to have_http_status :forbidden
    end

    it 'does not allow posting in locked conversations' do
      conversation.update locked: true, locked_by: create(:user, admin: true)

      expect do
        post :create, format: :json, params: {
          post: attributes_for(:post, conversation_id: conversation.id)
        }.merge(session)
      end.not_to change { Post.count }

      expect(response).to have_http_status :forbidden
    end

    it_behaves_like 'flood_limitable' do
      let :attributes do
        { post: attributes_for(:post, conversation_id: conversation.id) }.merge(session)
      end
    end
  end

  describe '#PATCH update' do
    let :post do
      create :post, author: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }
      end.not_to change { post.reload.attributes }

      expect(response).to have_http_status :unauthorized
    end

    it 'updates the attributes of a post' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }.merge(session)
      end.to change { post.reload.attributes }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'post'
    end

    it 'sets the editor when a post is modified' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }.merge(session)
      end.to change { post.reload.editor }.from(nil).to(active_user)

      expect(response).to have_http_status :ok
    end

    it 'does not allow editing posts not owned by the user' do
      post.update author: create(:user)

      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }.merge(session)
      end.not_to change { post.reload.attributes }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to edit posts owned by other users' do
      active_user.update admin: true
      post.update author: create(:user)

      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }.merge(session)
      end.to change { post.reload.attributes }

      expect(response).to have_http_status :ok
      expect(post.editor).to eq active_user
    end

    it 'prevents users from editing the deleted state of a post' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: { deleted: true } }.merge(session)
      end.not_to change { post.reload.deleted? }

      expect(response).to have_http_status :ok
    end

    it 'allows admins to edit the deleted state of a post' do
      active_user.update admin: true
      post.update deleted: true, deleted_by: active_user

      expect do
        patch :update, format: :json, params: { id: post.id, post: { deleted: false } }.merge(session)
      end.to change { post.reload.deleted? }.from(true).to(false)

      expect(response).to have_http_status :ok
    end

    it 'prevents users from changing the editor of a post' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: { editor_id: nil } }.merge(session)
      end.to change { post.reload.editor }.from(nil).to(active_user)

      expect(response).to have_http_status :ok
    end

    it 'allows admins to change the editor of a post' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: { id: post.id, post: { editor_id: nil } }.merge(session)
      end.not_to change { post.reload.editor }

      expect(response).to have_http_status :ok
    end

    it 'returns 404 when editing deleted posts' do
      post.update deleted: true, deleted_by: active_user

      expect do
        patch :update, format: :json, params: { id: post.id, post: attributes_for(:post) }.merge(session)
      end.not_to change { post.reload.attributes }

      expect(response).to have_http_status :not_found
    end

    it 'returns errors if the post is invalid' do
      expect do
        patch :update, format: :json, params: { id: post.id, post: { body: nil } }.merge(session)
      end.not_to change { post.reload.body }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :body
    end
  end

  describe '#DELETE destroy' do
    let :post do
      create :post, author: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, format: :json, params: { id: post.id }
      end.not_to change { post.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'marks a post as deleted' do
      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.to change { post.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end

    it 'prevents users from deleting posts they do not own' do
      post.update author: create(:user)

      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.not_to change { post.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to delete posts owned by other users' do
      active_user.update admin: true
      post.update author: create(:user)

      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.to change { post.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end

    it 'prevents users from deleting posts in locked conversations' do
      post.conversation.update locked: true, locked_by: create(:user, admin: true)

      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.not_to change { post.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'allows admins to delete posts in locked conversations' do
      active_user.update admin: true
      post.conversation.update locked: true, locked_by: create(:user, admin: true)

      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.to change { post.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end

    it 'returns 404 when trying to delete a post which is already marked as deleted' do
      post.update deleted: true, deleted_by: active_user

      expect do
        delete :destroy, format: :json, params: { id: post.id }.merge(session)
      end.not_to change { post.reload.deleted? }

      expect(response).to have_http_status :not_found
    end
  end
end
