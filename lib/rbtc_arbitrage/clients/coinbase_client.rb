module RbtcArbitrage
  module Clients
    class CoinbaseClient
      include RbtcArbitrage::Client

      # return a symbol as the name
      # of this exchange
      def exchange
        :coinbase
      end

      # Returns an array of Floats.
      # The first element is the balance in BTC;
      # The second is in USD.
      def balance
        if @options[:verbose]
          warning = "Coinbase doesn't provide a USD balance because"
          warning << " it connects to your bank account. Be careful, "
          warning << "because this will withdraw directly from your accounts."
          logger.warn warning
        end
        @balance ||= [interface.balance.to_f, max_float]
      end

      # Configures the client's API keys.
      def validate_env
        validate_keys :coinbase_key, :coinbase_address
      end

      # `action` is :buy or :sell
      def trade action
        interface.send("#{action}!".to_sym, @options[:volume])
      end

      # `action` is :buy or :sell
      # Returns a Numeric type.
      def price action
        method = "#{action}_price".to_sym
        @price ||= interface.send(method).to_f
      end

      # Transfers BTC to the address of a different
      # exchange.
      def transfer client
        interface.send_money client.address, @options[:volume]
      end

      def interface
        @interface ||= Coinbase::Client.new(ENV['COINBASE_KEY'])
      end

      def address
        @address ||= interface.receive_address.address
      end

      private

      def max_float
        Float::MAX
      end
    end
  end
end