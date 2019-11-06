# frozen_string_literal: true

require "sidekiq"
require "sidekiq-scheduler"
require "faraday"
require "redlock"
require "dotenv/load"
require_relative "../../config/initializers/redlock_manager"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CacheWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    redis ||= Redis.new(url: ENV["REDIS_URL"]) # TODO: вынести в инициализатор

    resp = Faraday.new("http://#{ENV["WEB_HOST"]}/task").get

    response = JSON.parse(resp.body)

    redis.setex("important_value", 60, response)
  end
end
