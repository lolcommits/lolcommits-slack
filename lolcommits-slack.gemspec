lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lolcommits/slack/version'

Gem::Specification.new do |spec|
  spec.name        = "lolcommits-slack"
  spec.version     = Lolcommits::Slack::VERSION
  spec.authors     = ["Matthew Hutchinson"]
  spec.email       = ["matt@hiddenloop.com"]
  spec.summary     = %q{Sends lolcommits to one (or more) Slack channels}
  spec.homepage    = "https://github.com/lolcommits/lolcommits-slack"
  spec.license     = "LGPL-3.0"
  spec.description = %q{Automatically post your lolcommits to Slack}

  spec.metadata = {
    "homepage_uri"      => "https://github.com/lolcommits/lolcommits-slack",
    "changelog_uri"     => "https://github.com/lolcommits/lolcommits-slack/blob/master/CHANGELOG.md",
    "source_code_uri"   => "https://github.com/lolcommits/lolcommits-slack",
    "bug_tracker_uri"   => "https://github.com/lolcommits/lolcommits-slack/issues",
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  spec.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3"

  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "lolcommits", ">= 0.14.2"

  spec.add_development_dependency "webmock"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
end
