require 'thor'
require 'mtgox'
require_relative 'rbtc_arbitrage/campbx.rb'
require 'bitstamp'
require 'btce'
Dir[File.expand_path('../rbtc_arbitrage/*', __FILE__)].each { |f| require f }

module RbtcArbitrage
end
