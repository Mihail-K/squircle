# frozen_string_literal: true
require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'active_scheduler'

namespace :resque do
  task setup: :environment

  task setup_schedule: :setup do
    require 'resque-scheduler'

    # Load schema from YAML file.
    resque_schedule = YAML.load_file('.schedule.yml')
    Resque.schedule = ActiveScheduler::ResqueWrapper.wrap(resque_schedule)
  end

  task scheduler: :setup_schedule
end
