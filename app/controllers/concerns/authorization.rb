module Authorization
  extend ActiveSupport::Concern

  def policy!(record, user = current_user)
    policy_denied! unless policy_class.new(user, record, params).allows? action_name
  end

  def policy_params(user = current_user)
    policy_class.params(user, action_name).permitted
  end

  def policy_scope(relation, user = current_user)
    policy_class.scope(user, relation).relation
  end

protected

  def policy_class
    "#{controller_name.singularize.camelize}Policy".constantize
  end

  def policy_denied!
    raise Policy::ActionNotAllowed, 'Action not allowed'
  end
end
