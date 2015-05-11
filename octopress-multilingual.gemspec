# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-multilingual/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress-multilingual"
  spec.version       = Octopress::Multilingual::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.email         = ["brandon@imathis.com"]
  spec.summary       = %q{Add multiple language features to your Jekyll site.}
  spec.homepage      = "https://github.com/octopress/multilingual"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n").grep(%r{^(bin\/|lib\/|assets\/|changelog|readme|license|language_key)}i)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", ">= 3.0.0.a", "< 4"

  spec.add_development_dependency "octopress"
  spec.add_development_dependency "octopress-linkblog"
  spec.add_development_dependency "clash"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "octopress-debugger"
end
