module RbtcArbitrage
  class CLI < Thor

    desc "arbitrage", "Get information about the current arbitrage levels."
    option :live, type: :boolean, default: false, desc: "Execute live trades."
    option :cutoff, type: :numeric, default: 2, desc: "The minimum profit level required to execute a trade."
    option :volume, type: :numeric, default: 0.01, desc: "The amount of bitcoins to trade per transaction."
    option :verbose, type: :boolean, default: true, desc: "Whether you wish to log information."
    option :buyer, type: :string, default: "btce"
    option :seller, type: :string, default: "campbx"
    option :repeat, type: :numeric, default: nil
    option :notify, type: :boolean, default: false
    def trade
      RbtcArbitrage::Trader.new(options).trade
    end

    default_task :trade

  end
end