# frozen_string_literal: true
class ReportsController < ApplicationController
  before_action :doorkeeper_authorize!

  before_action :set_reports, except: :create
  before_action :set_reportable, only: :create
  before_action :set_report, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @reports,
           each_serializer: ReportSerializer,
           meta: meta_for(@reports) if stale?(Report.where(id: @reports))
  end

  def show
    render json: @report if stale?(@report)
  end

  def create
    @report = Report.create!(report_params) do |report|
      report.creator = current_user
    end

    render json: @report, status: :created
  end

  def update
    @report.attributes = report_params
    @report.closed_by  = current_user if @report.status_changed?(from: 'open')
    @report.save!

    render json: @report
  end

  def destroy
    @report.soft_delete!(current_user)

    head :no_content
  end

private

  def set_reportable
    return not_found unless Report::ALLOWED_TYPES.include?(report_params[:reportable_type])
    policy_scope(report_params[:reportable_type].safe_constantize).find(report_params[:reportable_id])
  end

  def set_reports
    @reports = policy_scope(Report).includes(:creator, :reportable)
    @reports = @reports.where(params.permit(:status))
    @reports = @reports.includes(:deleted_by) if allowed_to?(:view_deleted_reports)
  end

  def set_report
    @report = @reports.find(params[:id])
  end
end
