# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'lolcommits/slack/version'

Gem::Specification.new do |spec|
  spec.name        = "lolcommits-slack"
  spec.version     = Lolcommits::Slack::VERSION
  spec.authors     = ["Matthew Hutchinson"]
  spec.email       = ["matt@hiddenloop.com"]

  spec.summary     = %q{Sends lolcommits to one (or more) Slack channels}
  spec.description = %q{Automatically post your lolcommits to Slack}
  spec.homepage    = "https://github.com/lolcommits/lolcommits-slack"
  spec.license     = "LGPL-3"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|features)/}) }
  spec.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  # limited by lolcommits yam gem dep (remove when yammer plugin extracted from
  # lolcommits)
  spec.add_runtime_dependency "rest-client", "~> 1.8"

  spec.add_development_dependency "lolcommits", "~> 0.9.5" # "~> 0.9.6" TODO: use 0.9.6 before releasing gem
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
