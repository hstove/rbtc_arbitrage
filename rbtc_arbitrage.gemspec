# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbtc_arbitrage/version'

Gem::Specification.new do |spec|
  spec.name          = "rbtc_arbitrage"
  spec.version       = RbtcArbitrage::VERSION
  spec.authors       = ["Hank Stoever"]
  spec.email         = ["hstove@gmail.com"]
  spec.description   = %q{A gem for conducting arbitrage with Bitcoin.}
  spec.summary       = %q{A gem for conducting arbitrage with Bitcoin.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "mtgox"
  spec.add_dependency "bitstamp"
  spec.add_dependency "activemodel", ">= 3.1"
  spec.add_dependency "activesupport", ">= 3.1"
  spec.add_dependency "thor"
  spec.add_dependency "btce"
  spec.add_dependency "bitstamp"
end
