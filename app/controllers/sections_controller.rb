class SectionsController < ApiController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_sections, except: :create
  before_action :set_section, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action :enforce_policy!

  def index
    render json: @sections,
           each_serializer: SectionSerializer,
           meta: meta_for(@sections)
  end

  def show
    render json: @section
  end

  def create
    @section = Section.create! section_params do |section|
      section.creator = current_user
    end

    render json: @section, status: :created
  end

  def update
    @section.update! section_params

    render json: @section
  end

  def destroy
    @section.update! deleted: true

    head :no_content
  end

private

  def set_sections
    @sections = policy_scope(Section)
    @sections = @sections.includes(:creator) if admin?
  end

  def set_section
    @section = @sections.find params[:id]
  end

  def apply_pagination
    @sections = @sections.page(params[:page]).per(params[:count])
  end
end