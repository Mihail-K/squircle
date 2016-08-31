require 'rails_helper'

RSpec.describe SectionsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :sections do
      create_list :section, 3
    end

    it 'returns a list of sections' do
      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json).to have_key :sections
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq sections.count
    end

    it 'does not return sections that are not visible' do
      sections.sample.update deleted: true

      get :index, format: :json

      expect(response).to have_http_status :ok
      expect(json[:meta][:total]).to eq sections.count - 1
    end

    it 'returns all sections for admin users' do
      active_user.update admin: true
      sections.sample.update deleted: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response).to have_http_status :ok
      expect(json[:meta][:total]).to eq sections.count
    end
  end

  describe '#POST create' do
    let :section_attributes do
      {
        title:       Faker::Book.title,
        description: Faker::Hipster.paragraph
      }
    end

    it 'requires an authenticated user' do
      post :create, format: :json, params: { section: section_attributes }

      expect(response).to have_http_status :unauthorized
      expect(Section.count).to eq 0
    end

    it 'only allows admins to create sections' do
      post :create, format: :json, params: { access_token: token.token, section: section_attributes }

      expect(response).to have_http_status :forbidden
      expect(Section.count).to eq 0
    end

    it 'creates a section' do
      active_user.update admin: true

      post :create, format: :json, params: { access_token: token.token, section: section_attributes }

      expect(response).to have_http_status :created
      expect(json).to have_key :section
      expect(Section.count).to eq 1
    end

    it 'returns errors if the section is not valid' do
      active_user.update admin: true

      post :create, format: :json, params: {
        access_token: token.token, section: section_attributes.merge(title: nil)
      }

      expect(response).to have_http_status :unprocessable_entity
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key :title
      expect(Section.count).to eq 0
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
      old_attributes = section.attributes

      patch :update, format: :json, params: { id: section.id, section: section_attributes }

      expect(response).to have_http_status :unauthorized
      expect(section.reload.attributes).to eq old_attributes
    end

    it 'only allows admins to edit sections' do
      old_attributes = section.attributes

      patch :update, format: :json, params: {
        access_token: token.token, id: section.id, section: section_attributes
      }

      expect(response).to have_http_status :forbidden
      expect(section.reload.attributes).to eq old_attributes
    end

    it 'edits a section when called by an admin' do
      active_user.update admin: true
      old_attributes = section.attributes

      patch :update, format: :json, params: {
        access_token: token.token, id: section.id, section: section_attributes
      }

      expect(response).to have_http_status :ok
      expect(section.reload.attributes).not_to eq old_attributes
    end

    it 'returns errors when the section is invalid' do
      active_user.update admin: true
      old_attributes = section.attributes

      patch :update, format: :json, params: {
        access_token: token.token, id: section.id, section: section_attributes.merge(title: nil)
      }

      expect(response).to have_http_status :unprocessable_entity
      expect(section.reload.attributes).to eq old_attributes
    end
  end
end
