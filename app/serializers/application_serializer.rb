class ApplicationSerializer < ActiveModel::Serializer
  def allowed_to?(permission)
    current_user.try(:allowed_to?, permission) || false
  end
end
