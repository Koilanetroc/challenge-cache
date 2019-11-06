# frozen_string_literal: true

require "sidekiq"
require "sidekiq-scheduler"
require "faraday"
require "dotenv/load"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

class CacheWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    redis ||= Redis.new(url: ENV["REDIS_URL"])

    resp = Faraday.new("http://#{ENV["WEB_HOST"]}/task").get

    response = JSON.parse(resp.body)

    response["cached_at"] = Time.now.to_i

    redis.setex("important_value", 60, response)
  end
end
