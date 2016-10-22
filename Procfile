web: bundle exec puma -C config/puma.rb
worker: QUEUE=critical,high,medium,low bundle exec rake jobs:work
cron: bundle exec rake jobs:cron
