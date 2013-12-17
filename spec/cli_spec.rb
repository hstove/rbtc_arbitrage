require 'spec_helper'

describe RbtcArbitrage::CLI do
  it "calls trade on new trader" do
    RbtcArbitrage::Trader.any_instance.should_receive(:trade)
    RbtcArbitrage::CLI.new.trade
  end
end