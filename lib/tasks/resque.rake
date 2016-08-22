require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task setup: :environment

  task setup_schedule: :setup do
    require 'resque-scheduler'

    # Load schema from YAML file.
    Resque.schedule = YAML.load_file('.schedule.yml')
  end

  task scheduler: :setup_schedule
end
