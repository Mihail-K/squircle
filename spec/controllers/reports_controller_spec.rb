require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  include_context 'authentication'

  describe '#GET index' do
    let! :reports do
      create_list :report, 5, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      get :index, format: :json

      expect(response).to have_http_status :unauthorized
    end

    it 'returns a list of reports created by the current user' do
      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'reports'

      expect(json[:reports].count).to eq reports.count
    end

    it 'returns only reports created by the current user' do
      other_user    = create(:user)
      other_reports = reports.sample(3).each do |report|
        report.update creator: other_user
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:reports].count).to eq reports.count - other_reports.count
    end

    it 'only returns reports that are in a visible state' do
      deleted_reports = reports.sample(3).each do |report|
        report.update deleted: true
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:reports].count).to eq reports.count - deleted_reports.count
    end

    it 'returns all reports for admin users' do
      active_user.update admin: true

      other_user    = create(:user)
      other_reports = reports.sample(3).each do |report|
        report.update creator: other_user
      end

      get :index, format: :json, params: session

      expect(response).to have_http_status :ok
      expect(json[:reports].count).to eq reports.count
    end

    it 'filters reports by status' do
      closed_reports = reports.sample(3).each do |report|
        report.update status: 'resolved', closed_by: active_user
      end

      get :index, format: :json, params: { status: 'resolved' }.merge(session)

      expect(response).to have_http_status :ok
      expect(json[:reports].count).to eq closed_reports.count
    end
  end

  describe '#GET show' do
    let :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      get :show, format: :json, params: { id: report.id }

      expect(response).to have_http_status :unauthorized
    end

    it 'returns the requested report' do
      get :show, format: :json, params: { id: report.id }.merge(session)

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'report'
    end

    it 'prevents users from viewing reports that they do not own' do
      report.update creator: create(:user)

      get :show, format: :json, params: { id: report.id }.merge(session)

      expect(response).to have_http_status :not_found
    end

    it 'prevents users from viewing deleted reports' do
      report.update deleted: true

      get :show, format: :json, params: { id: report.id }.merge(session)

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to view deleted reports' do
      active_user.update admin: true
      report.update deleted: true

      get :show, format: :json, params: { id: report.id }.merge(session)

      expect(response).to have_http_status :ok
    end

    it 'allows admins to reports owned by other users' do
      active_user.update admin: true
      report.update creator: create(:user)

      get :show, format: :json, params: { id: report.id }.merge(session)

      expect(response).to have_http_status :ok
    end
  end

  describe '#POST create' do
    let :user do
      create :user
    end

    it 'requires an authenticated user' do
      expect do
        post :create, format: :json, params: {
          report: attributes_for(:report, reportable_id: user.id, reportable_type: user.model_name.name)
        }
      end.not_to change { Report.count }

      expect(response).to have_http_status :unauthorized
    end

    it 'creates a report' do
      expect do
        post :create, format: :json, params: {
          report: attributes_for(:report, reportable_id: user.id, reportable_type: user.model_name.name)
        }.merge(session)
      end.to change { Report.count }.by(1)

      expect(response).to have_http_status :created
      expect(response).to match_response_schema 'report'
    end

    it 'prevents banned users from creating reports' do
      active_user.update banned: true

      expect do
        post :create, format: :json, params: {
          report: attributes_for(:report, reportable_id: user.id, reportable_type: user.model_name.name)
        }.merge(session)
      end.not_to change { Report.count }

      expect(response).to have_http_status :forbidden
    end

    it 'returns errors if the report is invalid' do
      expect do
        post :create, format: :json, params: {
          report: attributes_for(:report, reportable_id: nil, reportable_type: user.model_name.name)
        }.merge(session)
      end.not_to change { Report.count }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :reportable
    end
  end

  describe '#PATCH update' do
    let :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        patch :update, format: :json, params: {
          id: report.id, report: attributes_for(:report)
        }
      end.not_to change { report.reload.attributes }

      expect(response).to have_http_status :unauthorized
    end

    it 'allows the creator to update the attributes of a report' do
      expect do
        patch :update, format: :json, params: {
          id: report.id, report: attributes_for(:report)
        }.merge(session)
      end.to change { report.reload.attributes }

      expect(response).to have_http_status :ok
      expect(response).to match_response_schema 'report'
    end

    it 'prevents users from updating reports they do not own' do
      report.update creator: create(:user)

      expect do
        patch :update, format: :json, params: {
          id: report.id, report: attributes_for(:report)
        }.merge(session)
      end.not_to change { report.reload.attributes }

      expect(response).to have_http_status :not_found
    end

    it 'prevents users from changing the status of a report' do
      expect do
        patch :update, format: :json, params: {
          id: report.id, report: { status: 'resolved' }
        }.merge(session)
      end.not_to change { report.reload.status }

      expect(response).to have_http_status :ok
    end

    it 'allows admins to change the status of a report' do
      active_user.update admin: true

      expect do
        patch :update, format: :json, params: {
          id: report.id, report: { status: 'resolved' }
        }.merge(session)
      end.to change { report.reload.status }.from('open').to('resolved')

      expect(response).to have_http_status :ok
      expect(report.closed_by).to eq active_user
    end

    it 'returns errors if the report is invalid' do
      expect do
        patch :update, format: :json, params: {
          id: report.id, report: { description: nil }
        }.merge(session)
      end.not_to change { report.reload.attributes }

      expect(response).to have_http_status :unprocessable_entity
      expect(response).to match_response_schema 'errors'

      expect(json[:errors]).to have_key :description
    end
  end

  describe '#DELETE destroy' do
    let :report do
      create :report, :reportable_user, creator: active_user
    end

    it 'requires an authenticated user' do
      expect do
        delete :destroy, format: :json, params: { id: report.id }
      end.not_to change { report.reload.deleted? }

      expect(response).to have_http_status :unauthorized
    end

    it 'prevents users from deleting reports' do
      expect do
        delete :destroy, format: :json, params: { id: report.id }.merge(session)
      end.not_to change { report.reload.deleted? }

      expect(response).to have_http_status :forbidden
    end

    it 'return 404 for reports the user does not own' do
      report.update creator: create(:user)

      expect do
        delete :destroy, format: :json, params: { id: report.id }.merge(session)
      end.not_to change { report.reload.deleted? }

      expect(response).to have_http_status :not_found
    end

    it 'allows admins to mark a report as deleted' do
      active_user.update admin: true

      expect do
        delete :destroy, format: :json, params: { id: report.id }.merge(session)
      end.to change { report.reload.deleted? }.from(false).to(true)

      expect(response).to have_http_status :no_content
    end
  end
end
