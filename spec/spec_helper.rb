require 'simplecov'
require 'coveralls'
require 'codeclimate-test-reporter'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
  # CodeClimate::TestReporter::Formatter
]
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/rbtc_arbitrage/campbx.rb"
  add_filter "/bitstamp/"
end

require 'bundler'
Bundler.require(:default, :development)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_localhost = true
  c.ignore_hosts 'codeclimate.com'
  c.ignore_request do |request|
    # true
  end
  c.filter_sensitive_data("<COINBASE_KEY>") { ENV['COINBASE_KEY'] }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
