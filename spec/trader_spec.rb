require 'spec_helper'
describe RbtcArbitrage::Trader do
  let(:trader) { RbtcArbitrage::Trader.new(verbose: false) }
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
        keys.pop if client.new.exchange == :coinbase
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

    ["PASSWORD","USERNAME","EMAIL"].each do |key|
      key = "SENDGRID_#{key}"
      it "should raise if --notify and not ENV[#{key}]" do
        trader.sell_client.stub(:validate_env)
        trader.buy_client.stub(:validate_env)
        old_val = ENV[key]
        ENV[key] = nil
        trader.options[:notify] = true
        expect { trader.validate_env }.to raise_error(ArgumentError)
        trader.options[:notify] = false
        expect { trader.validate_env }.not_to raise_error
      end
    end
  end

  describe "#fetch_prices" do
    it "gets the right price set", :vcr do
      campbx_price = RbtcArbitrage::Clients::CampbxClient.new.price(:sell)
      btce_price = RbtcArbitrage::Clients::BtceClient.new.price(:buy)

      trader.fetch_prices

      #allow for recent price changes
      trader.seller[:price].should be_within(0.02).of(campbx_price)
      trader.buyer[:price].should be_within(0.02).of(btce_price)
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
        volume: 1,
        cutoff: 1,
        logger: nil,
        verbose: false,
        live: true,
        seller: :campbx,
        buyer: :btce,
        notify: true,
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
      trader.sell_client.should be_a(RbtcArbitrage::Clients::CampbxClient)
      trader.buy_client.should be_a(RbtcArbitrage::Clients::BtceClient)
    end

  end

  describe "#execute_trade" do
    it "should raise SecurityError if not live", :vcr do
      expect { trader.execute_trade }.to raise_error(SecurityError)
    end

    context "when live" do
      let(:trader) { RbtcArbitrage::Trader.new(verbose: false, cutoff: 100, live: true) }

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
      trader.should_receive(:notify)
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

    it "should repeat if specified" do
      trader.options[:repeat] = 10
      trader.should_receive(:fetch_prices)
      trader.should_receive(:trade).and_call_original
      trader.should_receive(:trade_again)
      trader.trade
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
    before :each do
      trader.buyer[:price] = 1
      trader.seller[:price] = 1
      trader.instance_variable_set :@percent, 1
      trader.instance_variable_set :@paid, 1
      trader.instance_variable_set :@received, 1
    end
    it "calls logger.info" do
      trader.logger.should_receive(:info).exactly(5).times
      trader.log_info
    end

    it "formats the log correctly" do
      FileUtils.mkdir_p('tmp')
      date = DateTime.now.strftime "%^b %e %Y %l"
      logger = Logger.new('tmp/log.info')
      logger.datetime_format = trader.logger.datetime_format
      trader.options[:logger] = logger
      trader.log_info
      contents = File.read("tmp/log.info")
      contents.should include(date)
      contents.should include(" INFO -- ")
    end
  end

  describe "#logger" do
    it { trader.logger.should == trader.options[:logger] }
  end

  describe "#trade_again" do
    before(:each) { trader.options[:repeat] = 10 }

    it "should call #trade" do
      trader.should_receive(:sleep).with(10)
      trader.should_receive(:trade)
      trader.trade_again
    end

    it "should create new clients" do
      buy_client = trader.buy_client
      sell_client = trader.sell_client
      trader.should_receive(:sleep)
      trader.should_receive(:trade)
      trader.trade_again
      buy_client.should_not == trader.buy_client
      sell_client.should_not == trader.sell_client
    end
  end

  describe "#client_for_exchange" do
    it "should raise if wrong market" do
      error = "Invalid exchange - 'test'"
      expect { trader.client_for_exchange(:test) }.to raise_error(ArgumentError, error)
    end
  end

  describe "#notify" do
    it "returns false when notify == false" do
      trader.notify.should == false
    end

    it "returns false unless cutoff < percent" do
      trader.options[:notify] = true
      trader.instance_variable_set :@percent, 1
      trader.notify.should == false
    end

    it "calls Sendgrid when notify == true" do
      trader.options[:notify] = true
      trader.instance_variable_set :@percent, 3
      trader.instance_variable_set :@paid, 5
      trader.instance_variable_set :@received, 6
      trader.buyer[:price] = 1
      trader.seller[:price] = 1

      trader.options[:logger].should_receive(:info)
      Pony.should_receive(:mail).with({
        to: ENV['SENDGRID_EMAIL'],
        body: trader.notification,
      })

      trader.notify
    end
  end

  describe "#setup_pony" do
    it "gets called on validation when --notify" do
      ["PASSWORD","USERNAME","EMAIL"].each do |key|
        key = "SENDGRID_#{key}"
        ENV[key] ||= "something"
      end
      trader.options[:notify] = true
      trader.should_receive(:setup_pony).once
      trader.validate_env
    end
    it "sets up pony correctly" do
      opts = {
        from: "info@example.org",
        subject: "rbtc_arbitrage notification",
        :via => :smtp,
        :via_options => {
          :address => 'smtp.sendgrid.net',
          :port => '587',
          :domain => 'heroku.com',
          :user_name => ENV['SENDGRID_USERNAME'],
          :password => ENV['SENDGRID_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      }
      Pony.should_receive(:options=).with(opts)
      trader.setup_pony
    end
  end

  describe "#notification" do
    it "includes the right values" do
      trader.instance_variable_set :@percent, 3
      trader.instance_variable_set :@paid, 5
      trader.instance_variable_set :@received, 8
      trader.buyer[:price] = 1.00453
      trader.seller[:price] = 3.50453

      value = trader.notification
      value.should include("$1.0")
      value.should include("$3.5")
      value.should include("$3.0")
      value.should include("3.0%")
    end
    context "--live" do
      it "should say that it made a trade"
    end
  end

end