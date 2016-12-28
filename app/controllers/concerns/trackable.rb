# frozen_string_literal: true
module Trackable
  extend ActiveSupport::Concern

  included do
    after_action :track_action
  end

private

  def track_action
    TrackJob.perform_later(user_id:    current_user&.id,
                           visit_id:   current_visit&.id,
                           controller: controller_name,
                           method:     request.method,
                           action:     action_name,
                           status:     response.status,
                           body:       response.body)
  end
end
