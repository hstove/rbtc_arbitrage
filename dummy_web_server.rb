# This is a dummy web server that will
# make it easy for us to run ruby
# scripts on Heroku.

require 'sinatra'

get '/' do
  "Hello, world"
end