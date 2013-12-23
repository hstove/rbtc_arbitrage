require 'spec_helper'

describe RbtcArbitrage do
  describe ".clients" do
    it "includes clients" do
      clients = RbtcArbitrage.clients
      clients.should include(RbtcArbitrage::Clients::MtGoxClient)
      clients.should include(RbtcArbitrage::Clients::BtceClient)
    end
  end
end