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

  describe RbtcArbitrage::Clients do
    RbtcArbitrage.clients.each do |client|
      required_methods = [:trade, :balance, :validate_env, :exchange]
      required_methods << [:price, :transfer, :address]
      required_methods.flatten!
      describe client do
        it "has all requred methods" do
          required_methods.each do |meth|
            client.new.methods.should include(meth)
          end
        end
      end
    end
  end
end