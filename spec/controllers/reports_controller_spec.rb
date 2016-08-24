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

    it 'returns all reports for admin users' do
      active_user.update admin: true

      get :index, format: :json, params: { access_token: token.token }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq reports.count
    end

    it 'allows filtering by report status' do
      active_user.update admin: true
      reports.sample.update status: 'resolved', closed_by: active_user

      get :index, format: :json, params: { access_token: token.token, status: 'resolved' }

      expect(response.status).to eq 200
      expect(json[:meta][:total]).to eq reports.select(&:resolved?).count
    end
  end

  describe '#PATCH' do
    let! :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      old_status = report.status

      patch :update, format: :json, params: {
        id: report.id, report: { status: :resolved }
      }

      expect(response.status).to eq 401
      expect(report.reload.status).to eq old_status
    end

    it 'allows the creator to update the description of a report' do
      old_description = report.description

      patch :update, format: :json, params: {
        access_token: token.token, id: report.id,
        report: { description: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 200
      expect(report.reload.description).not_to eq old_description
    end

    it 'only allows admin users to change the status of a report' do
      old_status = report.status

      patch :update, format: :json, params: {
        access_token: token.token, id: report.id, report: { status: :resolved }
      }

      expect(response.status).to eq 200
      expect(report.reload.status).to eq old_status
    end

    it 'updates the status of a report' do
      old_status = report.status
      active_user.update admin: true

      patch :update, format: :json, params: {
        access_token: token.token, id: report.id, report: { status: :resolved }
      }

      expect(response.status).to eq 200
      expect(report.reload.status).not_to eq old_status
      expect(report.status).to eq 'resolved'
    end

    it 'returns errors if the report is invalid' do
      old_description = report.description

      patch :update, format: :json, params: {
        access_token: token.token, id: report.id, report: { description: nil }
      }

      expect(response.status).to eq 422
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key :description

      expect(report.reload.description).to eq old_description
    end
  end
end
