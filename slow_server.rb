require 'sinatra'

get '/task' do
  sleep(2)
  'get response'
end
