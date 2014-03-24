module Bitstamp
  class Orders < Bitstamp::Collection
    def all(options = {})
      Bitstamp::Helper.parse_objects! Bitstamp::Net::post('/open_orders').body_str, self.model
    end

    def create(options = {})
      path = (options[:type] == Bitstamp::Order::SELL ? "/sell" : "/buy")
      Bitstamp::Helper.parse_object! Bitstamp::Net::post(path, options).body_str, self.model
    end

    def sell(options = {})
      options.merge!({type: Bitstamp::Order::SELL})
      self.create options
    end

    def buy(options = {})
      options.merge!({type: Bitstamp::Order::BUY})
      self.create options
    end

    def find(order_id)
      all = self.all
      index = all.index {|order| order.id.to_i == order_id}

      return all[index] if index
    end
  end

  class Order < Bitstamp::Model
    BUY  = 0
    SELL = 1

    attr_accessor :type, :amount, :price, :id, :datetime
    attr_accessor :error, :message

    def cancel!
      Bitstamp::Net::post('/cancel_order', {id: self.id}).body_str
    end
  end
end
