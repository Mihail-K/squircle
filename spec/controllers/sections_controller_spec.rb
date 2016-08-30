require 'rails_helper'

RSpec.describe SectionsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :sections do
      create_list :section, Faker::Number.between(1, 3)
    end

    it 'returns a list of sections' do
      get :index, format: :json

      expect(response.status).to eq 200
      expect(json).to have_key :sections
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq sections.count
    end

    it 'does not return sections that are not visible' do
      sections.sample.update deleted: true

      get :index, format: :json

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq sections.count - 1
    end

    it 'returns all sections for admin users' do
      active_user.update admin: true
      sections.sample.update deleted: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
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

      expect(response.status).to eq 401
      expect(Section.count).to eq 0
    end

    it 'only allows admins to create sections' do
      post :create, format: :json, params: { access_token: token.token, section: section_attributes }

      expect(response.status).to eq 403
      expect(Section.count).to eq 0
    end

    it 'creates a section' do
      active_user.update admin: true

      post :create, format: :json, params: { access_token: token.token, section: section_attributes }

      expect(response.status).to eq 201
      expect(json).to have_key :section
      expect(Section.count).to eq 1
    end

    it 'returns errors if the section is not valid' do
      active_user.update admin: true

      post :create, format: :json, params: {
        access_token: token.token, section: section_attributes.merge(title: nil)
      }

      expect(response.status).to eq 422
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key :title
      expect(Section.count).to eq 0
    end
  end
end
