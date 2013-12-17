require 'thor'
require 'mtgox'
require_relative 'rbtc_arbitrage/campbx.rb'
require 'bitstamp'
require 'btce'
Dir["#{File.dirname(__FILE__)}/rbtc_arbitrage/**/*.rb"].each { |f| require(f) }

module RbtcArbitrage
end
