require 'thor'
require 'mtgox'
require_relative 'rbtc_arbitrage/campbx.rb'
require 'bitstamp'
require 'btce'
require_relative 'rbtc_arbitrage/client.rb'
Dir["#{File.dirname(__FILE__)}/rbtc_arbitrage/**/*.rb"].each { |f| require(f) }

module RbtcArbitrage
  def self.clients
    RbtcArbitrage::Clients.constants.collect do |c|
      RbtcArbitrage::Clients.const_get(c)
    end
  end
end
