require 'thor'
require 'mtgox'
require 'bitstamp'
Dir[File.expand_path('../rbtc_arbitrage/*', __FILE__)].each { |f| require f }

module RbtcArbitrage
end
