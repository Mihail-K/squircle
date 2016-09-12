require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    it 'requires an authenticated user' do
      get :index

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of roles' do
      get :index, params: session

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema :roles
    end
  end
end
