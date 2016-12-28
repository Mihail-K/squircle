# frozen_string_literal: true
class TrackJob < ApplicationJob
  queue_as :low

  def perform(attributes)
    Event.create(attributes) do |event|
      event.body = JSON.parse(event.body) if event.body.is_a?(String)
    end
  end
end
