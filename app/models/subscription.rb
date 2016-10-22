# == Schema Information
#
# Table name: subscriptions
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  conversation_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_subscriptions_on_conversation_id              (conversation_id)
#  index_subscriptions_on_user_id                      (user_id)
#  index_subscriptions_on_user_id_and_conversation_id  (user_id,conversation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_62f01c28cf  (conversation_id => conversations.id)
#  fk_rails_933bdff476  (user_id => users.id)
#

class Subscription < ApplicationRecord
  belongs_to :user, inverse_of: :subscriptions
  belongs_to :conversation, inverse_of: :subscriptions

  validates :user, presence: true, uniqueness: { scope: :conversation }
  validates :conversation, presence: true
end
