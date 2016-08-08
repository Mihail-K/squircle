class UserSerializer < ActiveModel::Serializer
  attributes :id
  attributes :display_name
  attributes :created_at

  attributes :email, if: :can_view_email?
  attributes :email_confirmed_at, if: :can_view_email?

  attributes :first_name, if: :can_view_personal_data?
  attributes :last_name, if: :can_view_personal_data?
  attributes :date_of_birth, if: :can_view_personal_data?

  def can_view_email?
    object.id == current_user.try(:id)
  end

  def can_view_personal_data?
    object.id == current_user.try(:id)
  end
end
