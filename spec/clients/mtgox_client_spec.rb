require 'spec_helper'

describe RbtcArbitrage::Clients::MtGoxClient do
  let(:client) { RbtcArbitrage::Clients::MtGoxClient.new }
  before(:each) { client.validate_env }

  describe "#balance" do
    it "fetches the balance correctly", :vcr do
      balances = MtGox.balance
      balance = client.balance
      balance.should == [balances[0].amount.to_f, balances[1].amount.to_f]
    end
  end

  describe "#price" do
    [:buy, :sell].each do |action|
      it "fetches price for #{action} correctly", :vcr do
        client.price(action).should be_a(BigDecimal)
      end
    end

    it "calls MtGox" do
      hash = Hashie::Mash.new(buy: 10)
      hash.should_receive(:buy)
      MtGox.should_receive(:ticker) { hash }
      client.price(:sell)

      client.instance_variable_set(:@price, nil)
      hash = Hashie::Mash.new(sell: 10)
      hash.should_receive(:sell)
      MtGox.should_receive(:ticker) { hash }
      client.price(:buy)
    end
  end

  describe "#trade" do
    it "calls MtGox" do
      MtGox.should_receive(:sell!).with(0.01, :market)
      client.trade(:sell)

      MtGox.should_receive(:buy!).with(0.01, :market)
      client.trade(:buy)
    end
  end

  describe "#transfer" do
    it "calls MtGox correctly" do
      sell_client = RbtcArbitrage::Clients::BitstampClient.new
      MtGox.should_receive(:withdraw!).with(0.01, sell_client.address)
      client.transfer sell_client
    end
  end
end