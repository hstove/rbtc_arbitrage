require 'spec_helper'

describe Bitstamp::Orders do
  before { setup_bitstamp }

  describe :all, vcr: {cassette_name: 'bitstamp/orders/all'} do
    subject { Bitstamp.orders.all }
    it { should be_kind_of Array }
    describe "first order" do
      subject { Bitstamp.orders.all.first }
      its(:price) { should == "1.01" }
      its(:amount) { should == "1.00000000" }
      its(:type) { should == 0 }
      its(:datetime) { should == "2013-09-26 23:15:04" }
    end
  end

  describe :sell do
    context "no permission found", vcr: {cassette_name: 'bitstamp/orders/sell/failure'} do
      subject { Bitstamp.orders.sell(:amount => 1, :price => 1000) }
      it { should be_kind_of Bitstamp::Order }
      its(:error) { should == "No permission found" }
    end
    # context "bitcoins available", vcr: {cassette_name: 'bitstamp/orders/sell/success'} do
    #   subject { Bitstamp.orders.sell(:amount => 1, :price => 1000) }
    #   xit { should be_kind_of Bitstamp::Order }
    #   its(:error) { should be_nil }
    # end
  end

  describe :buy, vcr: {cassette_name: 'bitstamp/orders/buy'} do
    subject { Bitstamp.orders.buy(:amount => 1, :price => 1.01) }
    it { should be_kind_of Bitstamp::Order }
    its(:price) { should == "1.01" }
    its(:amount) { should == "1" }
    its(:type) { should == 0 }
    its(:datetime) { should == "2013-09-26 23:26:56.849475" }
    its(:error) { should be_nil }
  end
end
