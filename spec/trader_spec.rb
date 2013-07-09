require 'spec_helper'
describe RbtcArbitrage::Trader do
  before :each do
    @trader = RbtcArbitrage::Trader.new

    #clear env variables
    ["KEY", "SECRET", "ADDRESS"].each do |suffix|
      ["MTGOX", "BITSTAMP"].each do |prefix|
        key      = "#{prefix}_#{suffix}"
        ENV[key] = nil
      end
    end
  end

  describe "#validate_env" do
    it "should raise errors when missing env variable" do
      ["KEY", "SECRET", "ADDRESS"].each do |suffix|
        ["MTGOX", "BITSTAMP"].each do |prefix|
          key = "#{prefix}_#{suffix}"
          expect { @trader.validate_env }.to raise_error(ArgumentError, "Exiting because missing required ENV variable $#{key}.")
          ENV[key] = "some value"
        end
      end
    end
  end

  describe "#fetch_prices" do
    it "gets the right price set" do
      stamp_price = Bitstamp.ticker.ask.to_f
      mtgox_price = MtGox.ticker.buy
      
      @trader.fetch_prices

      #allow for recent price changes
      @trader.mtgox[:price].should be_within(0.02).of(mtgox_price)
      @trader.stamp[:price].should be_within(0.02).of(stamp_price)
    end
  end

end