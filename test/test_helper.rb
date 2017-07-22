$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# necessary libs from lolcommits (allowing plugin to run)
require 'git'
require 'lolcommits/runner'
require 'lolcommits/vcs_info'
require 'lolcommits/backends/git_info'

# lolcommit test helpers
require 'webmock/minitest'
require 'lolcommits/test_helpers/git_repo'
require 'lolcommits/test_helpers/fake_io'

if ENV['COVERAGE']
  if ENV['TRAVIS']
    require 'coveralls'
    Coveralls.wear!
  else
    require 'simplecov'
  end
end

# plugin gem test libs
require 'lolcommits/plugin/slack'
require 'minitest/autorun'

# swallow all debug output during test runs
def debug(msg); end
