web: bundle exec puma -C config/puma.rb
worker: QUEUE=* bundle exec rake jobs:work
cron: bundle exec rake jobs:cron
