class UserSerializer < ActiveModel::Serializer
  attribute :id
  attribute :display_name
  attribute :created_at

  attribute :email, if: :can_view_email?
  attribute :email_confirmed_at, if: :can_view_email?

  attribute :first_name, if: :can_view_personal_data?
  attribute :last_name, if: :can_view_personal_data?
  attribute :date_of_birth, if: :can_view_personal_data?

  has_many :characters
  has_many :created_characters

  def can_view_email?
    object.id == current_user.try(:id)
  end

  def can_view_personal_data?
    object.id == current_user.try(:id)
  end
end
