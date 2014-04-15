require 'spec_helper'

describe RbtcArbitrage::Clients::CampbxClient do
  let(:client) { RbtcArbitrage::Clients::CampbxClient.new }
  let(:campbx) { client.interface }

  before(:each) { client.validate_env }

  it { client.exchange.should == :campbx }

  describe "#balance" do
    it "fetches the balance correctly", :vcr do
      balances = campbx.my_funds
      expected = [balances["Total BTC"].to_f, balances["Total USD"].to_f]
      client.balance.should == expected
    end
  end

  describe "#price" do
    [:buy, :sell].each do |action|
      it "fetches price for #{action} correctly", :vcr do
        client.price(action).should be_a(Float)
      end
    end

    it "calls CampBX" do
      hash = Hashie::Mash.new("Best Bid" => 10)
      hash.should_receive(:[]).with("Best Bid")
      campbx.should_receive(:xticker) { hash }
      client.price(:sell)

      client.instance_variable_set(:@price, nil)
      hash = Hashie::Mash.new("Best Ask" => 10)
      hash.should_receive(:[]).with("Best Ask")
      campbx.should_receive(:xticker) { hash }
      client.price(:buy)
    end
  end

  describe "#trade" do
    it "calls CampBX" do
      client.instance_variable_set(:@price, 10)
      campbx.should_receive(:trade_enter).with("QuickSell",0.01,10)
      client.trade(:sell)

      client.instance_variable_set(:@price, 11)
      campbx.should_receive(:trade_enter).with("QuickBuy",0.01,11)
      client.trade(:buy)
    end
  end

  describe "#transfer" do
    it "calls CampBX correctly" do
      sell_client = RbtcArbitrage::Clients::BitstampClient.new
      campbx.should_receive(:send_btc).with(sell_client.address, 0.01)
      client.transfer sell_client
    end
  end

  describe "#address" do
    it "calls campbx" do
      campbx.should_receive(:get_btc_address).and_return({"Success" => "xxx"})
      client.address.should eq("xxx")
    end
  end
end