module RbtcArbitrage
  module Clients
    class MtGoxClient
      include RbtcArbitrage::Client

      def balance
        return @balance if @balance
        balances = MtGox.balance
        @balance = [balances[0].amount.to_f, balances[1].amount.to_f]
      end

      def validate_env
        validate_keys
        MtGox.configure do |config|
          config.key = ENV["MTGOX_KEY"]
          config.secret = ENV["MTGOX_SECRET"]
        end
      end

      def exchange
        :mtgox
      end

      # `action` is :buy or :sell
      def price action
        return @price if @price
        action = {
          buy: :sell,
          sell: :buy,
        }[action]
        @price = MtGox.ticker.send(action)
      end

      # `action` is :buy or :sell
      def trade action
        action = "#{action.to_s}!".to_sym
        MtGox.send(action, @options[:volume], :market)
      end

      def transfer other_client
        MtGox.withdraw! @options[:volume], other_client.address
      end
    end
  end
end