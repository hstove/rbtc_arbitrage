require 'spec_helper'

class Bitstamp::Coin < Bitstamp::Model;end
class Bitstamp::Coins < Bitstamp::Collection;end

describe Bitstamp::Coins do
  subject { Bitstamp::Coins.new }
  its(:name) { should eq 'coin' }
  its(:module) { should eq "bitstamp/coin" }
  its(:model) { should be Bitstamp::Coin }
  its(:path) { should eq "/api/coins" }
end
