# frozen_string_literal: true
class Loader
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def self.get(name)
    klass = "#{name}Loader".camelize.safe_constantize
    raise unless klass < Loader
    klass
  end

  def for(*)
    raise 'Method not implemented'
  end
end
