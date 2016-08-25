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

  describe '#GET show' do
    let! :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      get :show, format: :json, params: { id: report.id }

      expect(response.status).to eq 401
    end

    it 'returns the report as json' do
      get :show, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 200
      expect(json).to have_key :report
    end

    it 'prevents users from viewing reports created by other users' do
      report.update creator: create(:user)

      get :show, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 404
    end

    it 'prevents users from viewing deleted reports' do
      report.update deleted: true

      get :show, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 404
    end

    it 'returns a 404 if the report does not exist' do
      get :show, format: :json, params: { access_token: token.token, id: report.id + 1 }

      expect(response.status).to eq 404
    end

    it 'allows admins to view all reports' do
      report.update creator: create(:user)
      active_user.update admin: true

      get :show, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 200
      expect(json).to have_key :report
    end
  end

  describe '#POST create' do
    let :reportable do
      create :user
    end

    let :report_attributes do
      {
        reportable_id:   reportable.id,
        reportable_type: reportable.class.name,
        description:     Faker::Hipster.paragraph
      }
    end

    it 'requires an authenticated user' do
      post :create, format: :json, params: { report: report_attributes }

      expect(response.status).to eq 401
      expect(Report.count).to eq 0
    end

    it 'creates a report' do
      post :create, format: :json, params: {
        access_token: token.token, report: report_attributes
      }

      expect(response.status).to eq 201
      expect(json).to have_key :report
      expect(Report.count).to eq 1
    end

    it 'prevents banned users from creating reports' do
      active_user.update banned: true

      post :create, format: :json, params: {
        access_token: token.token, report: report_attributes
      }

      expect(response.status).to eq 403
      expect(Report.count).to eq 0
    end

    it 'returns errors if the report is invalid' do
      post :create, format: :json, params: {
        access_token: token.token, report: report_attributes.merge(description: nil)
      }

      expect(response.status).to eq 422
      expect(json).to have_key :errors
      expect(json[:errors]).to have_key :description
      expect(Report.count).to eq 0
    end
  end

  describe '#PATCH update' do
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

    it 'prevents users from updating reports created by other users' do
      old_description = report.description
      report.update creator: create(:user)

      patch :update, format: :json, params: {
        access_token: token.token, id: report.id,
        report: { description: Faker::Hipster.paragraph }
      }

      expect(response.status).to eq 404
      expect(report.reload.description).to eq old_description
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
      expect(report.closed_by).to eq active_user
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

  describe '#DELETE destroy' do
    let! :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      delete :destroy, format: :json, params: { id: report.id }

      expect(response.status).to eq 401
      expect(report.reload.deleted?).to be false
    end

    it 'prevents non-admins from deleting reports' do
      delete :destroy, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 403
      expect(report.reload.deleted?).to be false
    end

    it 'marks a report as deleted' do
      active_user.update admin: true

      delete :destroy, format: :json, params: { access_token: token.token, id: report.id }

      expect(response.status).to eq 204
      expect(report.reload.deleted?).to be true
    end
  end
end
