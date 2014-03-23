module RbtcArbitrage
  module TraderHelpers
    module Logger
      def logger
        @options[:logger]
      end

      def log_info
        lower_ex = @buy_client.exchange.to_s.capitalize
        higher_ex = @sell_client.exchange.to_s.capitalize
        logger.info "#{lower_ex}: $#{buyer[:price].round(2)}"
        logger.info "#{higher_ex}: $#{seller[:price].round(2)}"
        logger.info "buying #{@options[:volume]} btc from #{lower_ex} for $#{@paid.round(2)}"
        logger.info "selling #{@options[:volume]} btc on #{higher_ex} for $#{@received.round(2)}"

        log_profit
      end
      
      private

      def log_profit
        profit_msg = "profit: $#{(@received - @paid).round(2)} (#{@percent.round(2)}%)"
        if cutoff = @options[:cutoff]
          profit_msg << " is #{@percent < cutoff ? 'below' : 'above'} cutoff"
          profit_msg << " of #{cutoff}%."
        end
        logger.info profit_msg
      end
    end
  end
end