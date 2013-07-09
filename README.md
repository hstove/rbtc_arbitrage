# RbtcArbitrage

A Ruby gem for executing arbitrage between the MtGox and Bitstamp bitcoin exchanges.

[![Build Status](https://travis-ci.org/hstove/rbtc_arbitrage.png?branch=master)](https://travis-ci.org/hstove/rbtc_arbitrage)

## Installation

Install it yourself as:

    $ gem install rbtc_arbitrage

## Usage

After installing the gem, simply run `rbtc` in the command line.

#### Options

- **Live**: whether you want to actually execute trades. You must have configured your API keys and bitcoin addresses through the following environment variables:
	1. MTGOX_KEY
	2. MTGOX_SECRET
	2. MTGOX_ADDRESS
	2. BITSTAMP_KEY
	2. BITSTAMP_SECRET
	3. BITSTAMP_ADDRESS
	
- **Cutoff**: the minimum profit percentage required to execute a trade. Defaults to **%2.00**.
- **Volume**: The amount of bitcoins to trade per transaction. Defaults to **0.01** (the minimum transaction size).

#### Examples

	$ rbtc --live --cutoff 4
	$ rbtc --cutoff 0.5
	$ rbtc --cutoff 3 --volume 0.05
	$ rbtc
	
The output will look like this:

	07/08/2013 at 10:41AM
	Retrieving market information and balances
	Bitstamp: $74.0
	MtGox: $76.89
	buying 0.01 btc from Bitstamp for $0.74
	selling 0.01 btc on MtGox for $0.76
	profit: $0.02 (2.77%)


## Contributing

### Pull Requests are welcome!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
