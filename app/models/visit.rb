# frozen_string_literal: true
# == Schema Information
#
# Table name: visits
#
#  id         :uuid             not null, primary key
#  user_id    :integer
#  ip         :inet
#  remote_ip  :inet
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_visits_on_id       (id) UNIQUE
#  index_visits_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_09e5e7c20b  (user_id => users.id)
#

class Visit < ApplicationRecord
  attr_accessor :request

  belongs_to :user

  before_create :set_request_fields, if: -> { request.present? }

private

  def set_request_fields
    self.ip        = request.ip
    self.remote_ip = request.remote_ip
  end
end
