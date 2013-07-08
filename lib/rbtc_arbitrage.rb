require "rbtc_arbitrage/version"
require 'mtgox'
require 'bitstamp'

module RbtcArbitrage
	class << self
		attr_accessor :mtgox, :stamp
		def trade
			MtGox.configure do |config|
			  config.key = ENV["MTGOX_KEY"]
			  config.secret = ENV["MTGOX_SECRET"]
			end

			Bitstamp.setup do |config|
			  config.key = ENV["BITSTAMP_KEY"]
			  config.secret = ENV["BITSTAMP_SECRET"]
			end
	  	balances = MtGox.balance
	    stamp = {}; mtgox = {}
	    mtgox[:btc] = balances[0].amount.to_f
	    mtgox[:usd] = balances[1].amount.to_f
	    balances = Bitstamp.balance
	    stamp[:usd] = balances["usd_available"].to_f
	    stamp[:btc] = balances["btc_available"].to_f
	    amount_to_buy = 0.01
	    stamp[:price] = Bitstamp.ticker.ask.to_f
	    mtgox[:price] = MtGox.ticker.buy
	    prices = [stamp[:price], mtgox[:price]]
	    paid = prices.min * 1.005 * amount_to_buy
	    received = prices.max * 0.994 * amount_to_buy

	    puts "#{Time.now.strftime("Traded on %m/%d/%Y at %I:%M%p")}"
	    puts "Bitstamp: $#{stamp[:price].round(2)}"
	    puts "MtGox: $#{mtgox[:price].round(2)}"
	    lower_ex, higher_ex = stamp[:price] < mtgox[:price] ? [Bitstamp, MtGox] : [MtGox, Bitstamp]
	    puts "buying #{amount_to_buy} btc from #{lower_ex} for #{paid.round(2)}"
	    puts "selling #{amount_to_buy} btc on #{higher_ex} for #{received.round(2)}"
	    percent = ((received/paid - 1) * 100).round(2)
	    puts "profit: $#{(received - paid).round(2)} (#{percent.round(2)}%)"
	    puts "stamp usd: $#{stamp[:usd].round(2)} btc: #{stamp[:usd].round(2)}"
	    puts "mtgox usd: $#{mtgox[:usd].round(2)} btc: #{mtgox[:usd].round(2)}"

	    if stamp[:price] < mtgox[:price]
	      if paid > stamp[:usd] || amount_to_buy > mtgox[:btc]
	        # not enough funds!
	        puts "not enough funds. quitting"
	      else
	        # Bitstamp.orders.buy amount_to_buy, stamp[:price] + 0.001
	        # MtGox.sell! amount_to_buy, :market
	        # Bitstamp.transfer amount_to_buy, "1FvCdr7x9RD1uSt9FcgjPiKfNKiycfJ6E7"
	      end
	    else
	      puts "arbitrage is backwards."
	      puts "TODO: fix this!"
	      # MtGox.buy! amount_to_buy, :market
	      # Bitstamp.orders.sell amount_to_buy, stamp[:price] - 0.001
	      # MtGox.withdraw amount_to_buy, "1MoYG5GGy4awx7MQKT7VitibZNqmz92mY2"
	    end
	  end
	end
end
