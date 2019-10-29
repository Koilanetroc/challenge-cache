require 'sinatra'
require "faraday"

get '/' do
  conn = Faraday.new('http://localhost:3000/task')

  resp = conn.get

  resp.body
end
