class UserSerializer < ActiveModel::Serializer
  cache expires_in: 3.hours

  attribute :id
  attribute :display_name
  attribute :created_at

  attribute :email, if: :can_view_email?
  attribute :email_confirmed_at, if: :can_view_email?

  attribute :first_name, if: :can_view_personal_data?
  attribute :last_name, if: :can_view_personal_data?
  attribute :date_of_birth, if: :can_view_personal_data?

  attribute :characters_count
  attribute :created_characters_count

  has_many :characters do
    object.characters.first(10)
  end
  has_many :created_characters, serializer: CharacterSerializer do
    object.created_characters.first(10)
  end

  def can_view_email?
    object.id == current_user.try(:id) ||
    current_user.try(:admin?)
  end

  def can_view_personal_data?
    object.id == current_user.try(:id) ||
    current_user.try(:admin?)
  end
end
