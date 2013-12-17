module RbtcArbitrage
  class Trader
    attr_reader :buy_client, :sell_client, :received
    attr_accessor :buyer, :seller, :options

    def initialize config={}
      @buyer   = {}
      @seller  = {}
      @options = {}
      set_key config, :volume, 0.01
      set_key config, :cutoff, 2
      set_key config, :logger, Logger.new(STDOUT)
      set_key config, :verbose, true
      set_key config, :live, false
      exchange = config[:buyer] || :bitstamp
      @buy_client = client_for_exchange(exchange)
      exchange = config[:seller] || :mtgox
      @sell_client = client_for_exchange(exchange)
      self
    end

    def set_key config, key, default
      @options[key] = config.has_key?(key) ? config[key] : default
    end

    def trade
      fetch_prices
      log_info if options[:verbose]

      if options[:cutoff] > @percent && options[:live]
        raise SecurityError, "Exiting because real profit (#{@percent.round(2)}%) is less than cutoff (#{options[:cutoff].round(2)}%)"
      end

      execute_trade if options[:live]

      self
    end

    def execute_trade
      fetch_prices unless @paid
      validate_env
      raise SecurityError, "--live flag is false. Not executing trade." unless options[:live]
      get_balance
      if @percent > @options[:cutoff]
        if @paid > buyer[:usd] || @options[:volume] > seller[:btc]
          raise SecurityError, "Not enough funds. Exiting."
        else
          logger.info "Trading live!" if options[:verbose]
          @buy_client.buy
          @sell_client.sell
          @buy_client.transfer @sell_client
          # Bitstamp.orders.buy @options[:volume], buyer[:price] + 0.001
          # MtGox.sell! @options[:volume], :market
          # Bitstamp.transfer @options[:volume], ENV['MTGOX_ADDRESS']
        end
      else
        logger.info "Not trading live because cutoff is higher than profit." if @options[:verbose]
      end
    end

    def fetch_prices
      logger.info "Fetching exchange rates" if @options[:verbose]
      threads = [1,2].map do |n|
        Thread.new do
          if n == 1
            Thread.current[:output] = @buy_client.price :buy
          else
            Thread.current[:output] = @sell_client.price :sell
          end
        end
      end
      threads.each_with_index do |thread, i|
        thread.join
        if i == 0
          buyer[:price] = thread[:output]
        else
          seller[:price] = thread[:output]
        end
      end
      prices = [buyer[:price], seller[:price]]
      @paid = prices.min * 1.005 * @options[:volume]
      @received = prices.max * 0.994 * @options[:volume]
      @percent = ((received/@paid - 1) * 100).round(2)
    end

    def log_info
      lower_ex = @buy_client.exchange.to_s.capitalize
      higher_ex = @sell_client.exchange.to_s.capitalize
      logger.info "#{lower_ex}: $#{buyer[:price].round(2)}"
      logger.info "#{higher_ex}: $#{seller[:price].round(2)}"
      logger.info "buying #{@options[:volume]} btc from #{lower_ex} for $#{@paid.round(2)}"
      logger.info "selling #{@options[:volume]} btc on #{higher_ex} for $#{@received.round(2)}"
      logger.info "profit: $#{(@received - @paid).round(2)} (#{@percent.round(2)}%)"
    end

    def get_balance
      @seller[:btc], @seller[:usd] = @sell_client.balance
      @buyer[:btc], @buyer[:usd] = @buy_client.balance
    end

    def logger
      @options[:logger]
    end

    def validate_env
      [@sell_client, @buy_client].each do |client|
        client.validate_env
      end
    end

    def client_for_exchange market
      market = market.to_sym unless market.is_a?(Symbol)
      clazz = RbtcArbitrage::Clients.constants.find do |c|
        clazz = RbtcArbitrage::Clients.const_get(c)
        clazz.new.exchange == market
      end
      clazz = RbtcArbitrage::Clients.const_get(clazz)
      clazz.new @options
    end
  end
end