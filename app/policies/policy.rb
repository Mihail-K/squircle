class Policy
  attr_reader :user
  attr_reader :record
  attr_reader :params

  def initialize(user, record, params)
    @user   = user
    @record = record
    @params = params
  end

  def allows?(action_name)
    send "#{action_name}?" if respond_to? "#{action_name}?"
  end

  def klass
    klass? ? record : record.class
  end

  def klass?
    record.is_a? Class
  end

  def user?
    user.present?
  end

  def scope
    self.class.scope user, klass
  end

  def self.params(user, action_name)
    self::Params.new user, action_name
  end

  def self.scope(user, scope)
    self::Scope.new user, scope
  end

  class Params
    attr_reader :user
    attr_reader :action_name

    def initialize(user, action_name)
      @user        = user
      @action_name = action_name
    end

    def permitted
      [ ]
    end
  end

  class Scope
    attr_reader :user
    attr_reader :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def relation
      scope.none
    end
  end

  class ActionNotAllowed < StandardError
  end
end
