class Character < ActiveRecord::Base
  belongs_to :user, inverse_of: :characters
  belongs_to :creator, class_name: 'User'

  validates :name, presence: true
  validates :user, presence: true, on: :create
  validates :creator, presence: true

  before_validation :set_creator_from_user, if: 'creator.nil?'

  scope :visible, -> {
    where deleted: false
  }

  def set_creator_from_user
    self.creator = user
  end
end
