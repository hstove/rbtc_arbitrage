guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/rbtc_arbitrage/(.+)\.rb$})            { |m| "spec/#{m[1]}_spec.rb" }
end

