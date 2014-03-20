# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'binneroc/version'

Gem::Specification.new do |spec|
  spec.name          = "binneroc"
  spec.version       = Binneroc::VERSION
  spec.authors       = ["John T. Prince"]
  spec.email         = ["jtprince@gmail.com"]
  spec.summary       = %q{bins x, y data into discrete bins using constant time binning}
  spec.description   = %q{bins x, y data into discrete bins using constant time binning. Useful.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  [
    #["trollop", "~> 2.0.0"],
  ].each do |args|
    spec.add_dependency(*args)
  end

  [
    ["bundler", "~> 1.5.3"],
    ["rake"],
    ["rspec", "~> 2.14.1"], 
    ["rdoc", "~> 4.1.0"], 
    ["simplecov", "~> 0.8.2"],
  ].each do |args|
    spec.add_development_dependency(*args)
  end

end
