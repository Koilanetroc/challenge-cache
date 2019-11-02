# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "securerandom"
require 'dotenv/load'
require "json"

set :bind, "0.0.0.0"

get "/task" do
  sleep(2)

  content_type :json
  { token: SecureRandom.uuid, requested_at: Time.now.to_i }.to_json
end
