# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_path/version'

Gem::Specification.new do |spec|
  spec.name          = "hash_path"
  spec.version       = HashPath::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]

  spec.summary       = %q{Hash path query}
  spec.description   = %q{A hash path query support library}
  spec.homepage      = "https://github.com/hetznerZA/hash_path"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
end
