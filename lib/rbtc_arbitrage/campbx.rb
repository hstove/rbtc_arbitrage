## Ruby module for working with CampBX API
## May 2013
## based on glenbot's python work @ https://github.com/glenbot/campbx/

require 'json'
require 'net/http'
require 'uri'

module CampBX
  API_BASE = 'https://campbx.com/api/'

  # { method_name => [ url, auth?, [ parameters ] ] }
  # See: https://campbx.com/api.php for specifics.
  # Each method returns a Hash with JSON data from the API.
  # Some parameters are optional.
  CALLS = {
    'xdepth' => [ 'xdepth', FALSE, [] ],
    'xticker' => [ 'xticker', FALSE, [] ],
    'my_funds' => ['myfunds', TRUE, [] ],
    'my_orders' => ['myorders', TRUE, [] ],
    'my_margins' => ['mymargins', TRUE, [] ],
    'send_instant' => ['sendinstant', TRUE, [ 'CBXCode', 'BTCAmt' ] ],
    'get_btc_address' => ['getbtcaddr', TRUE, [] ],
    'send_btc' => ['sendbtc', TRUE, [ 'BTCTo', 'BTCAmt' ] ],
#   'dwolla' => [ nil, TRUE, [] ], # Coming Soon (TM)
    'trade_cancel' => ['tradecancel', TRUE, [ 'Type', 'OrderID' ] ],
    'trade_enter' => ['tradeenter', TRUE, [ 'TradeMode', 'Quantity', 'Price' ] ],
    'trade_advanced' => ['tradeadv', TRUE, [ 'TradeMode', 'Price', 'Quantity', 'FillType', 'DarkPool', 'Expiry' ] ],
#   'margin_buy' => [ nil, TRUE, [] ], # Coming Soon (TM)
#   'short_sell' => [ nil, TRUE, [] ], # Coming Soon (TM)
  }


  class API
    # CampBX API rate limiting probably per IP address (not account)
    # which is why we don't limit per instance
    @@last = Time.new(0)
    @username  = nil
    @password  = nil

    def initialize( username=nil, password=nil )
      @username = username
      @password = password

      # Build meta-methods for each API call
      CALLS.each do |name|
        define_singleton_method name[0], lambda { |*args|
          data = CALLS[name[0]]
          api_request( [data[0], data[1]], Hash[data[2].zip( args )] )
        }
      end
    end

    def api_request( info, post_data={} )
      url, auth = info
      uri = URI.parse(API_BASE + url + '.php')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl=TRUE
      # CampBX advises latency can be >4 minutes when markets are volatile
      http.read_timeout = 300
      res = nil

      request = Net::HTTP::Get.new(uri.request_uri)
      if auth then
        post_data.merge!({
          'user' => @username,
          'pass' => @password,
        })
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data( post_data )
      end

      # debug # need to test w/valid credentials
      #puts "Sending request to #{uri}"
      #puts "Post Data: #{post_data}"

      # CampBX API: max 1 request per 500ms
      delta = Time.now - @@last
      #puts delta*1000
      if delta*1000 <= 500 then
        #puts "sleeping! for #{0.5 - delta}"
        sleep(0.5 - delta)
      end

      res = http.request(request)
      @@last = Time.now # Update time after request returns

      if res.message == 'OK' then # HTTP OK
        JSON.parse( res.body )
      else # HTTP ERROR
        warn "HTTP Error: + #{res.code}"
      end

    end

  end

end