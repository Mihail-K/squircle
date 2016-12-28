# frozen_string_literal: true
require 'rails_helper'

RSpec.describe TrackJob, type: :job do
  it 'creates an event' do
    expect do
      TrackJob.perform_now(attributes_for(:event))
    end.to change { Event.count }.by(1)
  end
end
