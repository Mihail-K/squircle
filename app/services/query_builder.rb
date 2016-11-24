# frozen_string_literal: true
class QueryBuilder
  include Elasticsearch::DSL

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def build
    search do |q|
      q.query do |q|
        q.bool do |q|
          build_constraints(q)
          build_query(q)
        end
      end
    end
  end

private

  def build_constraints(q)
    %i(indexable_id indexable_type).each do |field|
      q.must do |q|
        q.term field => params[field]
      end if params[field].present?
    end
  end

  def build_query(q)
    q.must do |q|
      q.multi_match do |q|
        q.query  params[:query].presence || ''
        q.fields %w(primary primary.english^1.5
                    secondary secondary.english^1.5
                    tertiary tertiary.english^1.5)
      end
    end
  end
end
