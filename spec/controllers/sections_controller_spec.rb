# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SectionsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :sections do
      create_list :section, 3
    end

    it 'returns a list of sections' do
      get :index

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'sections'

      expect(json[:sections].count).to eq sections.count
    end

    it 'does not return sections that are not visible' do
      sections.sample.update deleted: true, deleted_by: active_user

      get :index

      expect(response).to have_http_status :ok
      expect(json[:sections].count).to eq sections.count - 1
    end

    it 'returns all sections for admin users' do
      active_user.roles << Role.find_by!(name: 'admin')
      sections.sample.update deleted: true, deleted_by: active_user

      get :index, params: { access_token: token.token }

      expect(response).to have_http_status :ok
      expect(json[:sections].count).to eq sections.count
    end
  end

  describe '#GET show' do
    let :section do
      create :section
    end

    it 'returns the requested section' do
      get :show, params: { id: section.id }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'section'
    end

    it 'returns 404 if the section is deleted' do
      section.update deleted: true, deleted_by: active_user

      get :show, params: { id: section.id }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted sections' do
      active_user.roles << Role.find_by!(name: 'admin')
      section.update deleted: true, deleted_by: active_user

      get :show, params: { id: section.id }.merge(session)

      expect(response).to have_http_status :ok
    end
  end

  describe '#POST create' do
    it 'requires an authenticated user' do
      expect do
        post :create, params: { section: attributes_for(:section) }
      end.not_to change { Section.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to create sections' do
      expect do
        post :create, params: { section: attributes_for(:section) }.merge(session)
      end.not_to change { Section.count }

      expect(response).to have_http_status :forbidden
    end

    it 'creates a section when called by an admin user' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: { section: attributes_for(:section) }.merge(session)
      end.to change { Section.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema 'section'
    end

    it 'returns errors if the section is not valid' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        post :create, params: {
          section: attributes_for(:section, title: nil)
        }.merge(session)
      end.not_to change { Section.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :title
    end
  end

  describe '#PATCH update' do
    let :section do
      create :section
    end

    let :section_attributes do
      { title: Faker::Book.title }
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, params: { id: section.id, section: section_attributes }
      end.not_to change { section.reload.title }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to edit sections' do
      expect do
        patch :update, params: { id: section.id, section: section_attributes }.merge(session)
      end.not_to change { section.reload.title }

      expect(response).to have_http_status :forbidden
    end

    it 'edits a section when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: section.id, section: section_attributes }.merge(session)
      end.to change { section.reload.title }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'section'
    end

    it 'returns errors when the section is invalid' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        patch :update, params: { id: section.id, section: { title: nil } }.merge(session)
      end.not_to change { section.reload.title }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :title
    end
  end

  describe '#DELETE destroy' do
    let :section do
      create :section
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, params: { id: section.id }
      end.not_to change { section.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'only allows admins to delete sections' do
      expect do
        delete :destroy, params: { id: section.id }.merge(session)
      end.not_to change { section.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'marks a section as deleted when called by an admin' do
      active_user.roles << Role.find_by!(name: 'admin')

      expect do
        delete :destroy, params: { id: section.id }.merge(session)
      end.to change { section.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
