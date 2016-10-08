class ApplicationSerializer < ActiveModel::Serializer
  def allowed_to?(permission)
    current_user.try(:allowed_to?, permission) || false
  end

  def policy_class
    "#{self.class.name.chomp('Serializer')}Policy".constantize
  end

  def policy
    @policy ||= policy_class.new(current_user, object)
  end
end
