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
end

require 'bundler'
Bundler.require

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_localhost = true
  c.ignore_hosts 'codeclimate.com'
  c.ignore_request do |request|
    # true
  end
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
