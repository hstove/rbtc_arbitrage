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
  spec.homepage      = "https://github.com/hstove/rbtc_arbitrage"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  # get an array of submodule dirs by executing 'pwd' inside each submodule
  `git submodule --quiet foreach pwd`.split($\).each do |submodule_path|
    # for each submodule, change working directory to that submodule
    Dir.chdir(submodule_path) do
      # issue git ls-files in submodule's directory
      submodule_files = `git ls-files`.split($\)
      # prepend the submodule path to create absolute file paths
      submodule_files_fullpaths = submodule_files.map do |filename|
        "#{submodule_path}/#{filename}"
      end
      # remove leading path parts to get paths relative to the gem's root dir
      # (this assumes, that the gemspec resides in the gem's root dir)
      submodule_files_paths = submodule_files_fullpaths.map do |filename|
        filename.gsub "#{File.dirname(__FILE__)}/", ""
      end
      # add relative paths to gem.files
      spec.files += submodule_files_paths
    end
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency "rake", "10.1.1"

  spec.add_dependency "faraday", "0.8.8"
  # spec.add_dependency "bitstamp"
  spec.add_dependency "activemodel", ">= 3.1"
  spec.add_dependency "activesupport", ">= 3.1"
  spec.add_dependency "thor"
  spec.add_dependency "btce", '0.2.4'
  spec.add_dependency "coinbase", '2.1.0'
  spec.add_dependency "pony"
  spec.add_dependency "tco", "0.1.0"
end
