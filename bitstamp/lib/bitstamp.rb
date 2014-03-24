require 'active_support/core_ext'
require 'active_support/inflector'
require 'active_model'
require 'curb'
require 'hmac-sha2'

require 'bitstamp/net'
require 'bitstamp/helper'
require 'bitstamp/collection'
require 'bitstamp/model'

require 'bitstamp/orders'
require 'bitstamp/transactions'
require 'bitstamp/ticker'

String.send(:include, ActiveSupport::Inflector)

module Bitstamp
  # API Key
  mattr_accessor :key

  # Bitstamp secret
  mattr_accessor :secret
  
  # Bitstamp client ID
  mattr_accessor :client_id

  # Currency
  mattr_accessor :currency
  @@currency = :usd

  def self.orders
    self.sanity_check!

    @@orders ||= Bitstamp::Orders.new
  end

  def self.user_transactions
    self.sanity_check!

    @@transactions ||= Bitstamp::UserTransactions.new
  end

  def self.transactions
    return Bitstamp::Transactions.from_api
  end

  def self.balance
    self.sanity_check!

    JSON.parse Bitstamp::Net.post('/balance').body_str
  end

  def self.ticker
    return Bitstamp::Ticker.from_api
  end

  def self.order_book
    return JSON.parse Bitstamp::Net.get('/order_book/').body_str
  end

  def self.setup
    yield self
  end
  
  def self.configured?
    self.key && self.secret && self.client_id
  end

  def self.sanity_check!
    unless configured?
      raise MissingConfigExeception.new("Bitstamp Gem not properly configured")
    end
  end

  class MissingConfigExeception<Exception;end;
end
