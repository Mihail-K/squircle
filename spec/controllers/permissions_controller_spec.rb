# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PermissionsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    it 'requires an authenticated user' do
      get :index

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of permissions' do
      get :index, params: { access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :permissions
    end
  end

  describe '#GET show' do
    let :permission do
      Permissible::Permission.first
    end

    it 'requires an authenticated user' do
      get :show, params: { id: permission.id }

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the specified permission' do
      get :show, params: { id: permission.id, access_token: access_token }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :permission
    end
  end
end
