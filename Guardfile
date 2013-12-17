guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/rbtc_arbitrage/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')             { 'spec' }
  watch(%r{^spec/clients/.+_spec\.rb$})
  watch(%r{^lib/rbtc_arbitrage/clients/(.+)\.rb$}) { |m| "spec/clients/#{m[1]}_spec.rb" }
end

