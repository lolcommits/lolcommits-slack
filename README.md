# Lolcommits Slack

[![Gem Version](https://img.shields.io/gem/v/lolcommits-plugin-sample.svg?style=flat)](http://rubygems.org/gems/lolcommits-plugin-sample)
[![Travis Build Status](https://travis-ci.org/lolcommits/lolcommits-plugin-sample.svg?branch=master)](https://travis-ci.org/lolcommits/lolcommits-plugin-sample)
[![Coverage Status](https://coveralls.io/repos/github/lolcommits/lolcommits-plugin-sample/badge.svg?branch=master)](https://coveralls.io/github/lolcommits/lolcommits-plugin-sample)
[![Code Climate](https://codeclimate.com/github/lolcommits/lolcommits-plugin-sample/badges/gpa.svg)](https://codeclimate.com/github/lolcommits/lolcommits-plugin-sample)
[![Gem Dependency Status](https://gemnasium.com/badges/github.com/lolcommits/lolcommits-plugin-sample.svg)](https://gemnasium.com/github.com/lolcommits/lolcommits-plugin-sample)

[lolcommits](https://lolcommits.github.io/) takes a snapshot with your webcam
every time you git commit code, and archives a lolcat style image with it. Git
blame has never been so much fun!

Lolcommit plugins are automatically loaded before the capturing process starts.
The flexible class design allows developers to add features by running code
before or after snapshots are taken.

This gem showcases an example plugin. It prints short messages to the screen
before and after every lolcommit. Something like this;

    ✨  Say cheese 😁 !
    *** Preserving this moment in history.
    📸  Snap
    ✨  wow! 9e6303c is your best looking commit yet! 😘  💻

Use this repo to jump-start development on your own plugin. It has good tests,
docs and working hooks to useful tools (Travis, CodeClimate, Rdoc etc.) See
below for more information on how to get started.

## Developing your own plugin

First, there are some things your gem *must* do to be loaded and executed
correctly. At the very least:

* Name your gem with the `lolcommits-` prefix.
* Include a class that inherits from `Lolcommits::Plugin::Base` (this will be
  the entry point to your plugin from the lolcommits gem).
* This main plugin class must meet the requirements explained below.
* Require `lolcommits` in your gem spec as a development dependency.

### Your Plugin Class

You plugin class must have a namespace and path that matches your gem name and
be in the `LOAD_PATH` (required) with the gem for example:

    # a gem named: lolcommits-zapier
    # should have a plugin class inheriting from Base like so:
    class Lolcommits::Plugin::Zapier < Lolcommits::Plugin::Base
      ...
    end
    # at lib/lolcommits/plugin/zapier.rb
    # required in a file at lib/lolcommits/zapier.rb

    # or a gem named: lolcommits-super-awesome
    # should have a plugin class
    class Lolcommits::Super::Awesome < Lolcommits::Plugin::Base
      ...
    end
    # at lib/lolcommits/super/awesome.rb

You **should** override the following methods in this class:

* `def self.name` - identifies the plugin to lolcommits and users, keep things
  simple and choose a name that matches your gem name.
* `def self.runner_order` - return the hooks this plugin should run at during
  the capture process (`:pre_capture`, `:post_capture` and/or `:capture_ready`).
* `def run_pre_capture`, `def run_post_capture` and/or `def run_capture_ready` -
  override with your plugin's behaviour.

Three hooks points are available during the lolcommits capture process.

* `:pre_capture` - called before the camera starts capturing, at this point you
  could alter the commit message/sha text.
* `:post_capture` - called immediately after the camera snaps the raw image (or
  video for gif captures) use this hook to alter the image, other plugins may
  hook here to modify the image too.
  `:capture_ready` - called after all `:post_capture` plugins have ran, at this
  point the capture should be ready for exporting or sharing.

### Plugin configuration

The `Base` class initializer defines an `@options` instance var, with an array
of setting names that the user can configure. By default, the only option is
`enabled` and plugins *must* be configured as `enabled = true` to run.

A plugin can be configured by the lolcommits gem with;

    lolcommits --config
    # or
    lolcommits --config -p plugin-name

Use the `configuration` method in your plugin class to read these options.
Plugin methods you may want to override with custom configuration code include:

* `def enabled?` - usually checks `configuration['enabled']` to determine if the
  plugin should run.
* `def configure_options!` - prompts the user for configuration (based on the
  `@options`) returns a hash that will be persisted.
* `def configured?` - checks the persisted config hash is present.
* `def valid_configuration?`- checks the persisted config hash has valid data.

If your plugin requires no configuration, you could override the `enabled?`
method to always return `true`. Users could disable your plugin by uninstalling
the gem.

By default a plugin will only run it's capture hooks if:

* `valid_configuration?` returns true
* `enabled?` returns true

For more help, check out [the
documentation](http://www.rubydoc.info/github/lolcommits/lolcommits-plugin-sample/Lolcommits/Plugin/Sample)
for this plugin, or take a look at [other
  lolcommit_plugins](https://github.com/search?q=topic%3Alolcommits-plugin+org%3Alolcommits&type=Repositories) in the wild.

### The Lolcommits 'runner'

The only required argument for your plugin class initializer is a
`Lolcommits::Runner` instance. By default, the base plugin initializer will set
this in the `runner` instance var.

Use these runner methods to access the commit, repo and configuration:

* `runner.message` - the git commit message.
* `runner.sha` - the git sha for the current commit.
* `runner.vcs_info` - a reference to the
  [Lolcommits::VCSInfo](https://github.com/mroth/lolcommits/blob/master/lib/lolcommits/vcs_info.rb)
  instance.
* `runner.config` - a reference to the
  [Lolcommits::Configuration](https://github.com/mroth/lolcommits/blob/master/lib/lolcommits/configuration.rb)
  instance.

After the capturing process has completed, (i.e. in the `run_post_capture` or
`run_capture_ready` hooks) these methods will reveal the captured snapshot file.

* `runner.snapshot_loc` - the raw image file.
* `runner.main_image` - the processed image file, resized, with text overlay
  applied (or any other effects from other plugins).

During plugin configuration, your plugin class will be initialized with the
optional `config` argument (and no runner). This allows you to read the existing
saved options during configuration. E.g. to show the existing options back to
the user.

Take a look at the
[Lolcommits::Runner](https://github.com/mroth/lolcommits/blob/master/lib/lolcommits/runner.rb)
for more details.

### Testing your plugin

It's a good idea to include tests with your gem. To make this easier for you,
the main lolcommits gem provides helpers to work with IO and Git repos in
test.

    # add one or both of these to your plugin's test_helper file
    require 'lolcommits/test_helpers/git_repo'
    require 'lolcommits/test_helpers/fake_io'

    # and include either (or both) modules in your test
    include Lolcommits::TestHelpers::GitRepo
    include Lolcommits::TestHelpers::FakeIO

Use the following methods to manage a test repo:

    setup_repo                 # create the test repo
    commit_repo_with_message   # perform a git commit in the test repo
    last_commit                # git commit info for the last commit in the test repo
    teardown_repo              # destroy the test repo
    in_repo(&block)            # run lolcommits within the test repo

For submitting and capturing IO use the `fake_io_capture` method. E.g. to
capture the output of the `configure_options` method, while sending the string
input 'true' (followed by a carriage return) when prompted on STDIN:

    output = fake_io_capture(inputs: %w(true)) do
      configured_plugin_options = plugin.configure_options!
    end

For more examples take a look at the [tests in this
repo](https://github.com/lolcommits/lolcommits-plugin-sample/blob/dev_guide/test/lolcommits/plugin/sample_test.rb)
(MiniTest).

### General advice

Use this gem as a starting point, renaming files, classes and references. Or
build a new plugin gem from scratch with:

    bundle gem lolcommits-my-plugin

For more examples, take a look at other published [lolcommit
plugins](https://github.com/lolcommits).

If you feel something is missing (or out of date) in this short guide. Please
create a new
[issue](https://github.com/lolcommits/lolcommits-plugin-sample/issues).

## History

Until recently, all plugins lived inside the main lolcommits gem. We are in the
process of extracting them to individual gems, loaded with the new plugin
manager. Ruby gem versioning will take care of managing dependencies and
compatibility with the main gem.

---

## Requirements

* Ruby >= 2.0.0
* A webcam
* [ImageMagick](http://www.imagemagick.org)
* [ffmpeg](https://www.ffmpeg.org) (optional) for animated gif capturing

## Installation

Follow the [install guide](https://github.com/mroth/lolcommits#installation) for
lolcommits first. Then run the following:

    $ gem install lolcommits-plugin-sample

Next configure and enable this plugin with:

    $ lolcommits --config -p plugin-sample
    # set enabled to `true`

That's it! Every lolcommit now comes with it's own short (emoji themed) message!

## Development

Check out this repo and run `bin/setup`, this will install dependencies and
generate docs. Run `bundle exec rake` to run all tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt that will allow you to
experiment with the gem code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

## Docs

Generate docs for this gem with:

    $ rake rdoc

## Troubles?

If you think something is broken or missing, please raise a new
[issue](https://github.com/lolcommits/lolcommits-plugin-sample/issues). Take
a moment to check it hasn't been raised in the past (and possibly closed).

## Contributing

Bug [reports](https://github.com/lolcommits/lolcommits-plugin-sample/issues) and [pull
requests](https://github.com/lolcommits/lolcommits-plugin-sample/pulls) are welcome on
GitHub.

When submitting pull requests, remember to add tests covering any new behaviour,
and ensure all tests are passing on [Travis
CI](https://travis-ci.org/lolcommits/lolcommits-plugin-sample). Read the
[contributing
guidelines](https://github.com/lolcommits/lolcommits-plugin-sample/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/lolcommits/lolcommits-plugin-sample/blob/master/CODE_OF_CONDUCT.md)
for more details.

## License

The gem is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Links

* [Travis CI](https://travis-ci.org/lolcommits/lolcommits-plugin-sample)
* [Test Coverage](https://coveralls.io/github/lolcommits/lolcommits-plugin-sample?branch=master)
* [Code Climate](https://codeclimate.com/github/lolcommits/lolcommits-plugin-sample)
* [RDoc](http://rdoc.info/projects/lolcommits/lolcommits-plugin-sample)
* [Issues](http://github.com/lolcommits/lolcommits-plugin-sample/issues)
* [Report a bug](http://github.com/lolcommits/lolcommits-plugin-sample/issues/new)
* [Gem](http://rubygems.org/gems/lolcommits-plugin-sample)
* [GitHub](https://github.com/lolcommits/lolcommits-plugin-sample)
