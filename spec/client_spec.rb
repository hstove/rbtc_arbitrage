require 'spec_helper'

class FakeClient
  include RbtcArbitrage::Client

  def trade action
  end
end

describe RbtcArbitrage::Client do
  let(:client) { FakeClient.new }
  it "aliases buy and sell" do
    client.should_receive(:trade).with(:sell)
    client.sell
    client.should_receive(:trade).with(:buy)
    client.buy
  end
end