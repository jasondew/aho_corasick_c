# -*- encoding: utf-8 -*-
require File.expand_path("../lib/aho_corasick/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Dew"]
  gem.email         = ["jdew@geezeo.com"]
  gem.description   = %q{Aho-Corasick searching via C}
  gem.summary       = %q{Aho-Corasick searching via C}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.extensions    = %w{ext/extconf.rb}
  gem.name          = "aho_corasick_c"
  gem.require_paths = ["lib"]
  gem.version       = AhoCorasick::VERSION
end
