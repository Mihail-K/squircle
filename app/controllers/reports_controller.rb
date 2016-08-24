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
           meta: {
             page:  @reports.current_page,
             count: @reports.limit_value,
             total: @reports.total_count,
             pages: @reports.total_pages
           }
  end

  def show
    render json: @report
  end

  def create
    @report = Report.new report_params do |report|
      report.creator = current_user
    end

    if @report.save
      render json: @report, status: :created
    else
      errors @report
    end
  end

  def update
    if @report.update report_params
      render json: @report
    else
      errors @report
    end
  end

  def destroy
    if @report.update deleted: true
      render json: @report
    else
      errors @report
    end
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
