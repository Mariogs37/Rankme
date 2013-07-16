# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rankme/version'

Gem::Specification.new do |spec|
  spec.name          = "rankme"
  spec.version       = Rankme::VERSION
  spec.authors       = ["Ben"]
  spec.email         = ["benjamin_clayman@alumni.brown.edu"]
  spec.description   = %q{This gem takes the 1v1 match results of two players
                        and generates updated ratings (and subsequently a ladder)
                        for these players}
  spec.summary       = %q{Ranking algorithm based on individual ratings}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
