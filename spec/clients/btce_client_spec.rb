require 'spec_helper'

describe RbtcArbitrage::Clients::BtceClient do
  let(:client) { RbtcArbitrage::Clients::BtceClient.new(verbose: false) }
  let(:btce) { client.interface }

  it { client.exchange.should == :btce }

  before(:each) do
    btce.stub(:get_info) {
      {
        "success" => 1,
        "return" => {
          "funds" => {
            "usd" => 2.57460659,
            "btc" => 0.00012226,
            "ltc" => 3.00815559,
            "nmc" => 0,
            "rur" => 8.0116908,
            "eur" => 0,
            "nvc" => 0,
            "trc" => 0,
            "ppc" => 0,
            "ftc" => 0,
            "xpm" => 0},
            "rights" => {
              "info" => 1,
              "trade" => 0,
              "withdraw" => 0
            },
            "transaction_count" => 120,
            "open_orders" => 1,
            "server_time"=>1385947487
          }
        }
      }
  end

  describe "#balance" do
    it "fetches the balance correctly", :vcr do
      balances = btce.get_info["return"]["funds"]
      expected = [balances["btc"], balances["usd"]]
      client.balance.should eql(expected)
      client.balance.each do |b|
        b.should be_a(Float)
      end
    end
  end

  describe "#price" do
    [:buy, :sell].each do |action|
      it "fetches price for #{action} correctly", :vcr do
        client.price(action).should be_a(Float)
      end
    end

    it "calls btc-e", :vcr do
      ticker = Btce::Ticker.new("btc_usd").json["ticker"]
      client.price(:sell).should == ticker["sell"]
      client.price(:buy).should == ticker["buy"]
    end
  end

  describe "#trade" do
    it "calls CampBX" do
      client.stub(:gets) { 'accept' }

      client.instance_variable_set(:@ticker, {"sell" => 10, "buy" => 11})
      opts = {pair: "btc_usd", type: :sell, rate: 10, amount: 0.01}
      btce.should_receive(:trade).with(opts)
      client.trade(:sell)

      opts[:type] = :buy
      opts[:rate] = 11
      btce.should_receive(:trade).with(opts)
      client.trade(:buy)
    end
  end

  describe "#transfer" do
    it "calls CampBX correctly" do
      client.options[:verbose] = true
      sell_client = RbtcArbitrage::Clients::BitstampClient.new
      client.options[:logger].should_receive(:error)
      client.transfer(sell_client)
    end
  end
end