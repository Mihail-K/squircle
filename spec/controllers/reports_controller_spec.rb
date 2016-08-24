require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  include_context 'authentication'

  let :json do
    JSON.parse(response.body).with_indifferent_access
  end

  describe '#GET index' do
    let! :reports do
      create_list :report, Faker::Number.between(1, 3), :reportable_user
    end

    it 'requires an authenticated user' do
      get :index, format: :json

      expect(response.status).to eq 401
    end

    it 'returns a list of reports created by the current user' do
      reports.sample.update creator: active_user

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json).to have_key :reports
      expect(json).to have_key :meta

      expect(json[:meta][:total]).to eq 1
    end

    it 'only returns reports that are in a visible state' do
      report = reports.sample
      report.update creator: active_user
      report.update deleted: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq 0
    end
  end
end
