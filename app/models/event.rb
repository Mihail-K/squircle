# frozen_string_literal: true
# == Schema Information
#
# Table name: events
#
#  id         :uuid             not null, primary key
#  user_id    :integer
#  visit_id   :uuid
#  controller :string           not null
#  method     :string           not null
#  action     :string           not null
#  status     :integer          not null
#  body       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_events_on_id       (id) UNIQUE
#  index_events_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_0cb5590091  (user_id => users.id)
#  fk_rails_ef9e5ff5fb  (visit_id => visits.id)
#

class Event < ApplicationRecord
  belongs_to :user
  belongs_to :visit, touch: true

  validates :controller, :method, :action, :status, presence: true
end
