# frozen_string_literal: true

require "sidekiq"
require "sidekiq-scheduler"
require "faraday"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CacheWorker
  include Sidekiq::Worker

  def perform
    logger.info "started"

    redis ||= Redis.new(url: ENV["REDIS_URL"]) # TODO: вынести в инициализатор

    resp = Faraday.new("http://localhost:5000/task").get

    response = JSON.parse(resp.body)

    redis.setex("wanted_value", 30, response)

    logger.info "finished"
  end
end
