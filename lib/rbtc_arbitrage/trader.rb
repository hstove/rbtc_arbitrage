module RbtcArbitrage
  class Trader
    include RbtcArbitrage::TraderHelpers::Notifier
    include RbtcArbitrage::TraderHelpers::Logger

    attr_reader :buy_client, :sell_client, :received
    attr_accessor :buyer, :seller, :options

    def initialize config={}
      opts = {}
      config.each do |key, val|
        opts[(key.to_sym rescue key) || key] = val
      end
      @buyer   = {}
      @seller  = {}
      @options = {}
      set_key opts, :volume, 0.01
      set_key opts, :cutoff, 2
      default_logger = Logger.new($stdout)
      default_logger.datetime_format = "%^b %e %Y %l:%M:%S %p %z"
      set_key opts, :logger, default_logger
      set_key opts, :verbose, true
      set_key opts, :live, false
      set_key opts, :repeat, nil
      set_key opts, :notify, false
      exchange = opts[:buyer] || :bitstamp
      @buy_client = client_for_exchange(exchange)
      exchange = opts[:seller] || :campbx
      @sell_client = client_for_exchange(exchange)
      self
    end

    def set_key config, key, default
      @options[key] = config.has_key?(key) ? config[key] : default
    end

    def trade
      fetch_prices
      log_info if options[:verbose]

      if options[:live] && options[:cutoff] > @percent
        raise SecurityError, "Exiting because real profit (#{@percent.round(2)}%) is less than cutoff (#{options[:cutoff].round(2)}%)"
      end

      execute_trade if options[:live]

      notify

      if @options[:repeat]
        trade_again
      end

      self
    end

    def trade_again
      sleep @options[:repeat]
      logger.info " - " if @options[:verbose]
      @buy_client = @buy_client.class.new(@options)
      @sell_client = @sell_client.class.new(@options)
      trade
    end

    def execute_trade
      fetch_prices unless @paid
      validate_env
      raise SecurityError, "--live flag is false. Not executing trade." unless options[:live]
      get_balance
      if @percent > @options[:cutoff]
        buy_and_transfer!
      else
        logger.info "Not trading live because cutoff is higher than profit." if @options[:verbose]
      end
    end

    def fetch_prices
      logger.info "Fetching exchange rates" if @options[:verbose]
      buyer[:price] = @buy_client.price(:buy)
      seller[:price] = @sell_client.price(:sell)
      prices = [buyer[:price], seller[:price]]

      calculate_profit
    end

    def get_balance
      @seller[:btc], @seller[:usd] = @sell_client.balance
      @buyer[:btc], @buyer[:usd] = @buy_client.balance
    end

    def validate_env
      [@sell_client, @buy_client].each do |client|
        client.validate_env
      end
      if options[:notify]
        ["PASSWORD","USERNAME","EMAIL"].each do |key|
          key = "SENDGRID_#{key}"
          unless ENV[key]
            raise ArgumentError, "Exiting because missing required ENV variable $#{key}."
          end
        end
        setup_pony
      end
    end

    def client_for_exchange market
      market = market.to_sym unless market.is_a?(Symbol)
      clazz = RbtcArbitrage::Clients.constants.find do |c|
        clazz = RbtcArbitrage::Clients.const_get(c)
        clazz.new.exchange == market
      end
      begin
        clazz = RbtcArbitrage::Clients.const_get(clazz)
        clazz.new @options
      rescue TypeError => e
        raise ArgumentError, "Invalid exchange - '#{market}'"
      end
    end

    private

    def calculate_profit
      @paid = buyer[:price] * 1.006 * @options[:volume]
      @received = seller[:price] * 0.994 * @options[:volume]
      @percent = ((received/@paid - 1) * 100).round(2)
    end

    def buy_and_transfer!
      if @paid > buyer[:usd] || @options[:volume] > seller[:btc]
        raise SecurityError, "Not enough funds. Exiting."
      else
        logger.info "Trading live!" if options[:verbose]
        @buy_client.buy
        @sell_client.sell
        @buy_client.transfer @sell_client
      end
    end

  end
end