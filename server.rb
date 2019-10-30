# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "faraday"
require "redis"
require "sidekiq"
require "json"
require "active_support/all"

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

  redis_key = "wanted_value"

  30.times do |i|
    @value = @redis.get redis_key

    break unless @value.nil?

    sleep 0.1
    logger.warn "Bzzzz"
  end

  # TODO: добавить статусы
  if @value.nil?
    { error: "no_data" }.to_json
  else
    parsed_value = eval(@value)

    ttl_secs = @redis.ttl(redis_key)
    expires_at = Time.now + ttl_secs.seconds

    last_modified_at = Time.at(parsed_value["requested_at"])

    expires expires_at, :public, :must_revalidate
    etag parsed_value["token"]
    last_modified last_modified_at

    @value
  end
end
