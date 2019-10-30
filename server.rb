# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "faraday"
require "redis"
require "sidekiq"
require "json"

require_relative "app/workers/cache_worker"

use Rack::Logger

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

helpers do
  def logger
    request.logger
  end
end

before do
  @redis ||= Redis.new(url: ENV["REDIS_URL"])
end

get "/" do
  content_type :json

  logger.info "trying to get values from cache..."

  30.times do |i|
    @value = @redis.get("wanted_value")

    break unless @value.nil?

    sleep 0.1
    logger.warn "Bzzzz"
  end

  if @value.nil?
    { error: "no_data" }.to_json
  else
    @value
  end
end
