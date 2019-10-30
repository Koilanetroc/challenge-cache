# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "faraday"
require "redis"
require "json"

use Rack::Logger

helpers do
  def logger
    request.logger
  end
end

before do
  @redis ||= Redis.new(url: ENV["REDIS_URL"])
end

get "/" do
  resp = Faraday.new("http://localhost:5000/task").get

  response = JSON.parse(resp.body)

  @redis.setex("wanted_value", 30, response)

  content_type :json
  response.to_json
end
