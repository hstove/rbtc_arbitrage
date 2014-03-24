require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.allow_http_connections_when_no_cassette = false
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.configure_rspec_metadata!
  c.filter_sensitive_data('BITSTAMP_KEY') do |interaction|
    ENV['BITSTAMP_KEY']
  end
  c.filter_sensitive_data('BITSTAMP_SECRET') do |interaction|
    ENV['BITSTAMP_SECRET']
  end
end

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end