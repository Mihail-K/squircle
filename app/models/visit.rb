# == Schema Information
#
# Table name: visits
#
#  id         :integer          not null, primary key
#  token      :uuid             not null
#  user_id    :integer
#  ip         :inet
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_visits_on_token    (token) UNIQUE
#  index_visits_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_09e5e7c20b  (user_id => users.id)
#

class Visit < ApplicationRecord
  belongs_to :user
end
