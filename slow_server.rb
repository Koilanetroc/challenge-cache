# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "securerandom"
require "json"


get "/task" do
  sleep(2)

  content_type :json
  { token: SecureRandom.uuid, requested_at: Time.now.to_i }.to_json
end
