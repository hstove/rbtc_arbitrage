module RbtcArbitrage
  module TraderHelpers
    module Logger
      def logger
        @options[:logger]
      end

      def log_info
        lower_ex = @buy_client.exchange.to_s.capitalize
        higher_ex = @sell_client.exchange.to_s.capitalize
        logger.info "#{lower_ex}: $#{color(buyer[:price].round(2))}"
        logger.info "#{higher_ex}: $#{color(seller[:price].round(2))}"
        logger.info log_string("buying", lower_ex, @paid)
        logger.info log_string("selling", lower_ex, @received)

        log_profit
      end

      private

      def log_string action, exchange, amount
        message = "#{action} #{color @options[:volume]} "
        message << "btc at #{exchange} for $"
        message << color(amount.round(2))
      end

      def color message
        message.to_s.fg("#D5EC28").bg("#000")
      end

      def log_profit
        profit_msg = "profit: $#{color (@received - @paid).round(2)}"
        profit_msg << " (#{color(@percent.round(2))}%)"
        if cutoff = @options[:cutoff]
          profit_msg << " is #{@percent < cutoff ? 'below' : 'above'} cutoff"
          profit_msg << " of #{color(cutoff)}%."
        end
        logger.info profit_msg
      end
    end
  end
end