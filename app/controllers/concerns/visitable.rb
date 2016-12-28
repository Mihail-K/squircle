# frozen_string_literal: true
module Visitable
  extend ActiveSupport::Concern

  included do
    after_action :track_visit, prepend: true, if: -> { request.headers.key?('X-Visit-ID') }
  end

  def current_visit_id
    request.headers['X-Visit-ID']
  end

  def current_visit
    return @current_visit if defined?(@current_visit)
    @current_visit = Visit.find_by(id: current_visit_id) if current_visit_id.present?
  end

private

  def track_visit
    response.headers['X-Visit-ID'] = current_visit_id.presence || create_visit.id
  end

  def create_visit
    Visit.create(user: current_user, request: request)
  end
end
