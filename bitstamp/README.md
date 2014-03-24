# Bitstamp Ruby API

Feel free to fork, modify & redistribute under the MIT license.

## Installation

Add this line to your application's Gemfile:

    gem 'bitstamp'

## Create API Key

More info at: [https://www.bitstamp.net/article/api-key-implementation/](https://www.bitstamp.net/article/api-key-implementation/)
    
## Setup

```ruby
Bitstamp.setup do |config|
  config.key = YOUR_API_KEY
  config.secret = YOUR_API_SECRET
  config.client_id = YOUR_BITSTAMP_USERNAME
end
```

If you fail to set your `key` or `secret` or `client_id` a `MissingConfigExeception`
will be raised.

## Bitstamp ticker

The bitstamp ticker. Returns `last`, `high`, `low`, `volume`, `bid` and `ask`

```ruby
Bitstamp.ticker
```

It's also possible to query through the `Bitstamp::Ticker` object with
each individual method.

```ruby
Bitstamp::Ticker.low     # => "109.00"
```

## Fetch your open order

Returns an array with your open orders.

```ruby
Bitstamp.orders.all
```

## Create a sell order

Returns an `Order` object.

```ruby
Bitstamp.orders.sell(amount: 1.0, price: 111)
```

## Create a buy order

Returns an `Order` object.

```ruby
Bitstamp.orders.buy(amount: 1.0, price: 111)
```

## Fetch your transactions

Returns an `Array` of `UserTransaction`.

```ruby
Bitstamp.user_transactions.all
```

*To be continued!**

# Tests

If you'd like to run the tests you need to set the following environment variables:

```
export BITSTAMP_KEY=xxx
export BITSTAMP_SECRET=yyy
export BITSTAMP_CLIENT_ID=zzz
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b
my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


