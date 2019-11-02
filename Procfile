main_server: bundle exec ruby server.rb -p 3000
slow_server: bundle exec ruby slow_server.rb -p 5000
worker: bundle exec sidekiq -r ./app/workers/cache_worker.rb -C ./config/sidekiq.yml
