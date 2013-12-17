module RbtcArbitrage
  module Client
    attr_accessor :options
    attr_writer :balance

    def initialize config={}
      @options = config
      @options = {}
      set_key config, :volume, 0.01
      set_key config, :cutoff, 2
      set_key config, :logger, Logger.new(STDOUT)
      set_key config, :verbose, true
      set_key config, :live, false
      self
    end

    def validate_keys
      ["KEY", "SECRET", "ADDRESS"].each do |suffix|
        prefix = exchange.to_s.upcase
        key = "#{prefix}_#{suffix}"
        if ENV[key].blank?
          raise ArgumentError, "Exiting because missing required ENV variable $#{key}."
        end
      end
    end

    def buy
      trade :buy
    end

    def sell
      trade :sell
    end

    private

    def set_key config, key, default
      @options[key] = config.has_key?(key) ? config[key] : default
    end
  end
end