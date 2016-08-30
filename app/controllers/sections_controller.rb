class SectionsController < ApiController
  include Political::Authority

  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_sections, except: :create
  before_action :set_section, except: %i(index create)
  before_action :apply_pagination, only: :index

  before_action { policy!(@section || Section) }

  def index
    render json: @sections,
           each_serializer: SectionSerializer,
           meta: meta_for(@sections)
  end

  def show
    render json: @section
  end

  def create
    @section = Section.new section_params

    if @section.save
      render json: @section, status: :created
    else
      errors @section
    end
  end

  def update
    if @section.update section_params
      render json: @section
    else
      errors @section
    end
  end

  def destroy
    if @section.update deleted: true
      head :no_content
    else
      errors @section
    end
  end

private

  def section_params
    params.require(:section).permit *policy_params
  end

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
