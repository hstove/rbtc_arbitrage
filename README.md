# RbtcArbitrage

A Ruby gem for executing arbitrage between different Bitcoin exchanges. Supports:

- Bitstamp
- CampBX
- BTC-E
- Coinbase
- ~~MtGox~~ (deprecated)

## Meta

Please contribute with code! There are always new exchanges that could be easily supported.
Check out the [contribution guidelines](https://github.com/hstove/rbtc_arbitrage/blob/master/CONTRIBUTING.md)
for instructions. Earn Bitcoin for every commit:

[![tip for next commit](http://tip4commit.com/projects/698.svg)](http://tip4commit.com/projects/698)

- [Explanation of bitcoin arbitrage](http://hankstoever.com/posts/13-Everything-you-need-to-know-about-Bitcoin-arbitrage)
- [Why I open sourced a bitcoin arbitrate bot](http://hankstoever.com/posts/2-Why-I-open-sourced-a-bitcoin-arbitrage-bot)
- I made a course about [using this to run your own arbitrage bot](https://www.uludum.org/funds/2).
- [CHANGELOG](https://github.com/hstove/rbtc_arbitrage/releases).

Donations accepted: **16BMcqf93eEpb2aWgMkJCSQQH85WzrpbdZ**

[![Build Status](https://travis-ci.org/hstove/rbtc_arbitrage.png?branch=master)](https://travis-ci.org/hstove/rbtc_arbitrage)
[![Coverage Status](https://coveralls.io/repos/hstove/rbtc_arbitrage/badge.png)](https://coveralls.io/r/hstove/rbtc_arbitrage)
[![Code Climate](https://codeclimate.com/github/hstove/rbtc_arbitrage.png)](https://codeclimate.com/github/hstove/rbtc_arbitrage)

## Installation

Install it yourself as:

    $ gem install rbtc_arbitrage

## Usage

After installing the gem, simply run `rbtc` in the command line.

#### Options

- **Live**: whether you want to actually execute trades. See the 'Environment
Variable' section for the required keys.
- **Cutoff**: the minimum profit percentage required to execute a trade. Defaults to **%2.00**.
- **Volume**: The amount of bitcoins to trade per transaction. Defaults to **0.01** (the minimum transaction size).
- **Buyer**: The exchange you'd like to buy bitcoins from during arbitrage. Default is `bitstamp`
- **Seller**: The exchange you'd like to sell bitcoins from during arbitrage. Default is `campbx`

Valid exchanges for the `--buyer` and `--seller` option are `bitstamp`, `campbx`,
`btce`,and `coinbase`.

#### Examples

~~~
	$ rbtc --live --cutoff 4
	$ rbtc --cutoff 0.5
	$ rbtc --cutoff 3 --volume 0.05
	$ rbtc --seller bitstamp --buyer campbx
	$ rbtc
~~~

The output will look like this:

~~~
I, [APR  6 2014  7:14:33 AM -0700#52261]  INFO -- : Fetching exchange rates
I, [APR  6 2014  7:14:37 AM -0700#52261]  INFO -- : Bitstamp (Ask): $455.0
I, [APR  6 2014  7:14:37 AM -0700#52261]  INFO -- : Campbx (Bid): $455.05
I, [APR  6 2014  7:14:37 AM -0700#52261]  INFO -- : buying 0.01 btc at Bitstamp for $4.58
I, [APR  6 2014  7:14:37 AM -0700#52261]  INFO -- : selling 0.01 btc at Campbx for $4.52
I, [APR  6 2014  7:14:37 AM -0700#52261]  INFO -- : profit: $-0.05 (-1.18%) is below cutoff of 2%.
~~~

### Environment Variables

You will need to configure the following environment variables
to trade with real accounts.

##### `BitstampClient`

*   BITSTAMP_KEY
*   BITSTAMP_SECRET
*   BITSTAMP_ADDRESS
*   BITSTAMP_CLIENT_ID

##### `CampbxClient`

- CAMPBX_KEY
- CAMPBX_SECRET

##### `BtceClient`

*   BTCE_KEY
*   BTCE_SECRET
*   BTCE_ADDRESS

##### `CoinbaseClient`

*   COINBASE_KEY
*   COINBASE_SECRET

## Exchange Adapters

`rbtc_arbtitrage` also exposes a handy interface for interacting with different
bitcoin clients. For example:

~~~ruby
client = RbtcArbitrage::Clients::BitstampClient.new
client.price :buy
 => 462.88
client.price :sell
 => 462.88
client.balance
 => [0.0079, 1.41] # [btc, usd]
client.options[:volume] = 0.5 # default is 0.01
# client.trade uses market price
client.trade :buy
client.trade :sell
client.address # for deposits
 => "16rQQYMTTKb9cnnSX3xYkN4hcKXoYcXXXX"
# send btc to an address
coinbase = RbtcArbitrage::Clients::CoinbaseClient.new
client.transfer coinbase.address
~~~
