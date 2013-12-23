require 'spec_helper'

describe RbtcArbitrage::Clients::BitstampClient do
  let(:client) { RbtcArbitrage::Clients::BitstampClient.new }
  before(:each) { client.validate_env }

  describe "#balance" do
    it "fetches the balance correctly", :vcr do
      balances = Bitstamp.balance
      client.balance.should == [balances["usd_available"].to_f, balances["btc_available"].to_f]
    end
  end

  describe "#price" do
    [:buy, :sell].each do |action|
      it "fetches price for #{action} correctly", :vcr do
        client.price(action).should be_a(Float)
      end
    end

    [[:bid, :sell], [:ask, :buy]].each do |actions|
      it "calls Bistamp with #{actions[0]}" do
        hash = Hashie::Mash.new("#{actions[0]}".to_sym => 10)
        hash.should_receive(:"#{actions[0]}")
        Bitstamp.should_receive(:ticker) { hash }
        client.price(actions[1])
      end
    end
  end

  describe "#trade" do
    [:buy, :sell].each do |action|
      it "trades on Bitstamp with #{action}" do
        client.instance_variable_set("@price", 1)
        trade_price = {
          :buy => 1.001,
          :sell => 0.999,
        }[action]
        bitstamp_options = {:amount => 0.01, :price => trade_price}
        Bitstamp.orders.should_receive(action).with(bitstamp_options)
        client.trade(action)
      end
    end
  end

  describe "#transfer" do
    it "calls Bitstamp correctly" do
      sell_client = RbtcArbitrage::Clients::MtGoxClient.new
      Bitstamp.should_receive(:transfer).with(0.01, sell_client.address)
      client.transfer sell_client
    end
  end
end