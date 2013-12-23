require 'spec_helper'

describe RbtcArbitrage::Clients::CoinbaseClient do
  let(:client) { RbtcArbitrage::Clients::CoinbaseClient.new }
  let(:coinbase) { client.interface }

  it { client.exchange.should == :coinbase }

  describe "#balance" do
    it "fetches the balance correctly", :vcr do
      balance = coinbase.balance.to_f
      expected = [balance, Float::MAX]
      client.balance.should eql(expected)
      client.balance.each do |b|
        b.should be_a(Float)
      end
    end

    it "should warn about USD balance" do
      client.options[:verbose] = true
      client.options[:logger].should_receive :warn
      client.instance_variable_set :@balance, [1, 1]
      client.balance
    end
  end

  describe "#price" do
    [:buy, :sell].each do |action|
      it "fetches price for #{action} correctly", :vcr do
        client.price(action).should be_a(Float)
      end
    end

    it "calls coinbase", :vcr do
      client.price(:buy).should == coinbase.buy_price.to_f
      client.instance_variable_set :@price, nil
      client.price(:sell).should == coinbase.sell_price.to_f
    end
  end

  describe "#trade" do
    it "calls coinbase" do
      coinbase.should_receive(:sell!).with(0.01)
      client.trade(:sell)

      coinbase.should_receive(:buy!).with(0.01)
      client.trade(:buy)
    end
  end

  describe "#transfer" do
    it "calls coinbase correctly" do
      sell_client = RbtcArbitrage::Clients::BtceClient.new
      coinbase.should_receive(:send_money).with(sell_client.address, 0.01)
      client.transfer(sell_client)
    end
  end

  describe "#address" do
    it "calls coinbase correctly" do
      response = Hashie::Mash.new(address: "hi")
      coinbase.should_receive(:receive_address) { response }
      client.address
    end
  end
end