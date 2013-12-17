# RbtcArbitrage

A Ruby gem for executing arbitrage between the MtGox and Bitstamp bitcoin exchanges.

[![Build Status](https://travis-ci.org/hstove/rbtc_arbitrage.png?branch=master)](https://travis-ci.org/hstove/rbtc_arbitrage)
[![Coverage Status](https://coveralls.io/repos/hstove/rbtc_arbitrage/badge.png)](https://coveralls.io/r/hstove/rbtc_arbitrage)
[![Code Climate](https://codeclimate.com/github/hstove/rbtc_arbitrage.png)](https://codeclimate.com/github/hstove/rbtc_arbitrage)

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
	4. BITSTAMP_CLIENT_ID

- **Cutoff**: the minimum profit percentage required to execute a trade. Defaults to **%2.00**.
- **Volume**: The amount of bitcoins to trade per transaction. Defaults to **0.01** (the minimum transaction size).
- **Buyer**: The exchange you'd like to buy bitcoins from during arbitrage. `"mtgox"` or `"bitstamp"`. Default is `bitstamp`
- **Seller**: The exchange you'd like to sell bitcoins from during arbitrage. `"mtgox"` or `"bitstamp"`. Default is `bitstamp`

#### Examples

	$ rbtc --live --cutoff 4
	$ rbtc --cutoff 0.5
	$ rbtc --cutoff 3 --volume 0.05
	$ rbtc --seller bitstamp --buyer mtgox
	$ rbtc

The output will look like this:

	07/08/2013 at 10:41AM
	Retrieving market information and balances
	Bitstamp: $74.0
	MtGox: $76.89
	buying 0.01 btc from Bitstamp for $0.74
	selling 0.01 btc on MtGox for $0.76
	profit: $0.02 (2.77%)

## Changelog

### 2.0.0

- full refactor
- 100% test coverage
- Modularized exchange-specific code to allow for easier extension.
- CLI `buyer` and `seller` option.

## Contributing

### Pull Requests are welcome!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Adding an exchange

Right now there is support for only MtGox and Bitstamp, but adding support for other exchanges is dead simple. First, you'll need to create a new `client` in `lib/rbtc_arbitrage/clients`. Follow the example from the [mtgox client](https://github.com/hstove/rbtc_arbitrage/blob/master/lib/rbtc_arbitrage/clients/mtgox_client.rb). You'll need to provide custom implementations of the following methods:

- `validate_env`
- `balance`
- `price`
- `trade`
- `exchange`

Make sure that the methods accept the same arguments and return similar objects. At the same time, make sure you copy the [mtgox_cient_spec](https://github.com/hstove/rbtc_arbitrage/blob/master/spec/clients/mtgox_client_spec.rb) and change it to test your client.