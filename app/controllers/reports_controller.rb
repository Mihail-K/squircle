class ReportsController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!

  before_action :set_reports, except: :create
  before_action :set_report, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action { policy!(@report || Report) }

  def index
    render json: @reports,
           each_serializer: ReportSerializer,
           meta: meta_for(@reports)
  end

  def show
    render json: @report
  end

  def create
    @report = Report.create! report_params do |report|
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
    @report.update! deleted: true

    head :no_content
  end

private

  def report_params
    params.require(:report).permit *policy_params
  end

  def set_reports
    @reports = policy_scope(Report).includes(:creator, :reportable)
    @reports = @reports.where(status: params[:status]) if params.key?(:status)
  end

  def set_report
    @report = @reports.find params[:id]
  end

  def apply_pagination
    @reports = @reports.page(params[:page]).per(params[:count])
  end
end
