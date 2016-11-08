# frozen_string_literal: true
class SectionsController < ApplicationController
  before_action :doorkeeper_authorize!, except: %i(index show)

  before_action :set_sections
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
    @section = @sections.create!(section_params) do |section|
      section.creator = current_user
    end

    render json: @section, status: :created
  end

  def update
    @section.update!(section_params)

    render json: @section
  end

  def destroy
    @section.soft_delete!(current_user)

    head :no_content
  end

private

  def set_sections
    @sections = policy_scope(Section)
    @sections = @sections.includes(:creator) if allowed_to?(:create_sections)
    @sections = @sections.includes(:deleted_by) if allowed_to?(:view_deleted_sections)
  end

  def set_section
    @section = @sections.find(params[:id])
  end
end
