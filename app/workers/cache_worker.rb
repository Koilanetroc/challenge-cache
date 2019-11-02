# frozen_string_literal: true

require "sidekiq"
require "sidekiq-scheduler"
require "faraday"
require "redlock"
require 'dotenv/load'
require_relative "../../config/initializers/redlock_manager"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CacheWorker
  include Sidekiq::Worker

  def perform
    redis ||= Redis.new(url: ENV["REDIS_URL"]) # TODO: вынести в инициализатор

    lock_key = "worker_is_locked"

    @lock = RedlockManager.current.lock(lock_key, 28000) # QUESTION: а нужен ли лок вообще?

    logger.info @lock

    return unless @lock

    resp = Faraday.new("http://#{ENV["WEB_HOST"]}/task").get # TODO: вынести адрес в окружение

    response = JSON.parse(resp.body)

    redis.setex("wanted_value", 30, response)
  rescue => error
    RedlockManager.current.unlock(@lock)

    raise error # Reraise
  end
end
