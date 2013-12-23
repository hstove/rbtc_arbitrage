require 'spec_helper'
describe RbtcArbitrage::Trader do
  let(:trader) { RbtcArbitrage::Trader.new({:verbose => false}) }
  describe "#validate_env" do

    before :each do
      @old_keys = {}
      #clear env variables
      ["KEY", "SECRET"].each do |suffix|
        RbtcArbitrage.clients.each do |client_class|
          key      = "#{client_class.new.exchange.to_s.upcase}_#{suffix}"
          @old_keys[key] = ENV[key]
          ENV[key] = nil
        end
      end
    end

    after :each do
      @old_keys ||= {}
      @old_keys.each do |k,v|
        ENV[k] = v
      end
    end

    RbtcArbitrage.clients.each do |client|
      describe client do
        keys = ["KEY", "SECRET"]
        keys << "ADDRESS" unless client.instance_methods(false).include?(:address)
        client = client.new
        prefix = client.exchange.to_s.upcase
        keys.each do |suffix|
          key = "#{prefix}_#{suffix}"
          it "should raise errors when missing env variable $#{key}" do
            expect { client.validate_env }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  describe "#fetch_prices" do
    it "gets the right price set", :vcr do
      stamp_price = Bitstamp.ticker.ask.to_f
      mtgox_price = MtGox.ticker.buy

      trader.fetch_prices

      #allow for recent price changes
      trader.buyer[:price].should be_within(0.02).of(stamp_price)
      trader.seller[:price].should be_within(0.02).of(mtgox_price)
    end

    it "calculates profit and percent accurately" do
      trader.buy_client.stub(:price) { 10.5 }
      trader.sell_client.stub(:price) { 10 }

      trader.fetch_prices
      trader.instance_variable_get(:@paid).should == (10.5 * 1.006 * 0.01)
      trader.instance_variable_get(:@received).should == (10 * 0.994 * 0.01)
    end
  end

  describe "#initialize" do
    let(:options) {
      {
        :volume => 1,
        :cutoff => 1,
        :logger => nil,
        :verbose => false,
        :live => true,
        :seller => :bitstamp,
        :buyer => :mtgox,
      }
    }

    let(:trader) { RbtcArbitrage::Trader.new(options) }

    it "sets the right options" do
      trader #memoize
      options.each do |k,v|
        next if [:seller,:buyer].include?(k)
        trader.options[k].should == v
      end
    end

    it "sets the right exchanges" do
      trader.buy_client.should be_a(RbtcArbitrage::Clients::MtGoxClient)
      trader.sell_client.should be_a(RbtcArbitrage::Clients::BitstampClient)
    end

  end

  describe "#execute_trade" do
    it "should raise SecurityError if not live", :vcr do
      expect { trader.execute_trade }.to raise_error(SecurityError)
    end

    context "when live" do
      let(:trader) { RbtcArbitrage::Trader.new({:verbose => false, :cutoff => 100, :live => true}) }

      it "shouldn't raise security error", :vcr do
        expect { trader.execute_trade }.not_to raise_error
      end

      it "should fetch balance", :vcr do
        trader.should_receive(:get_balance)
        trader.execute_trade
      end

      it "raises SecurityError if not enough USD", :vcr do
        trader.instance_variable_set :@percent, 101
        trader.instance_variable_set :@paid, 10000
        trader.buyer[:usd] = 0
        expect { trader.execute_trade }.to raise_error(SecurityError)
      end

      it "raises SecurityError if not enough BTC", :vcr do
        trader.instance_variable_set :@percent, 101
        trader.instance_variable_set :@paid, 1
        trader.buyer[:usd] = 2
        trader.options[:volume] = 1
        trader.seller[:btc] = 0
        expect { trader.execute_trade }.to raise_error(SecurityError)
      end

      it "should buy and sell" do
        trader.instance_variable_set :@percent, 101
        trader.instance_variable_set :@paid, 1
        trader.buyer[:usd] = 2
        trader.options[:volume] = 1
        trader.seller[:btc] = 2
        trader.should_receive :get_balance
        trader.buy_client.should_receive(:buy)
        trader.sell_client.should_receive(:sell)
        trader.buy_client.should_receive(:transfer).with(trader.sell_client)
        trader.execute_trade
      end
    end
  end

  describe "#trade" do
    it "calls the right methods" do
      trader.should_receive(:fetch_prices)
      trader.should_not_receive(:log_info)
      trader.should_not_receive(:execute_trade)

      trader.instance_variable_set :@percent, 0

      trader.trade
    end

    it "raises SecurityError if cutoff > percent" do
      trader.options[:live] = true
      trader.options[:cutoff] = 10
      trader.instance_variable_set :@percent, 1

      trader.should_receive(:fetch_prices)
      trader.should_not_receive(:log_info)

      expect { trader.trade }.to raise_error(SecurityError)
    end

    it "calls #execute_trade if percent > cutoff" do
      trader.options[:live] = true
      trader.options[:cutoff] = 1
      trader.instance_variable_set :@percent, 10

      trader.should_receive(:fetch_prices)
      trader.should_not_receive(:log_info)
      trader.should_receive(:execute_trade)

      trader.trade
    end
  end

  describe "#log_info" do
    it "calls logger.info" do
      trader.buyer[:price] = 1
      trader.seller[:price] = 1
      trader.instance_variable_set :@percent, 1
      trader.instance_variable_set :@paid, 1
      trader.instance_variable_set :@received, 1
      trader.logger.should_receive(:info).exactly(5).times
      trader.log_info
    end
  end

  describe "#logger" do
    it { trader.logger.should == trader.options[:logger] }
  end

end