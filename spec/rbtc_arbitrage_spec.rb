require 'spec_helper'

describe RbtcArbitrage do
  describe ".clients" do
    it "includes clients" do
      clients = RbtcArbitrage.clients
      clients.should include(RbtcArbitrage::Clients::CampbxClient)
      clients.should include(RbtcArbitrage::Clients::BitstampClient)
    end
  end
end