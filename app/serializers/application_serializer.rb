# frozen_string_literal: true
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

  def respond_to_missing?(method_name, include_private = false)
    method_name =~ /^allowed_to_(\w+)\?$/ || super
  end

  def method_missing(method_name, *args, &block)
    method_name =~ /^allowed_to_(\w+)\?$/ ? allowed_to?($1) : super
  end
end
