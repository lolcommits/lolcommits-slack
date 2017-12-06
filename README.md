# Lolcommits Slack

[![Gem Version](https://img.shields.io/gem/v/lolcommits-slack.svg?style=flat)](http://rubygems.org/gems/lolcommits-slack)
[![Travis Build Status](https://travis-ci.org/lolcommits/lolcommits-slack.svg?branch=master)](https://travis-ci.org/lolcommits/lolcommits-slack)
[![Maintainability](https://img.shields.io/codeclimate/maintainability/lolcommits/lolcommits-slack.svg)](https://codeclimate.com/github/lolcommits/lolcommits-slack/maintainability)
[![Test Coverage](https://img.shields.io/codeclimate/c/lolcommits/lolcommits-slack.svg)](https://codeclimate.com/github/lolcommits/lolcommits-slack/test_coverage)
[![Gem Dependency Status](https://gemnasium.com/badges/github.com/lolcommits/lolcommits-slack.svg)](https://gemnasium.com/github.com/lolcommits/lolcommits-slack)

[lolcommits](https://lolcommits.github.io/) takes a snapshot with your webcam
every time you git commit code, and archives a lolcat style image with it. Git
blame has never been so much fun!

This plugin automatically posts your lolcommits to one (or more)
[Slack](https://slack.com) channels.

The Slack post will contain the git commit message and repo name. The SHA is
used as the uploaded image file name. Posting will be retried (once) should any
error occur.

## Requirements

* Ruby >= 2.0.0
* A webcam
* [ImageMagick](http://www.imagemagick.org)
* [ffmpeg](https://www.ffmpeg.org) (optional) for animated gif capturing

## Installation

Follow the [install guide](https://github.com/mroth/lolcommits#installation) for
lolcommits first. Then run the following:

    $ gem install lolcommits-slack

## Configuration

Next configure and enable with:

    $ lolcommits --config -p slack
    # set enabled to `true`
    # enter your access token and Slack channel ID list (see below)

That's it! Every lolcommit will now be posted to these Slack channels. To
disable simply reconfigure with `enabled: false`.

### Access Token

This plugin uses Slack [legacy
tokens](https://api.slack.com/custom-integrations/legacy-tokens) for
authentication. Create (or grab) them
[here](https://api.slack.com/custom-integrations/legacy-tokens).

### Channel List

You must supply one or more Slack channel *IDs*. You can use Slack's own
[API testing tool](https://api.slack.com/methods/channels.list/test)
to list all Slack channels in your account, and grab the IDs from the JSON
response presented.

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
[issue](https://github.com/lolcommits/lolcommits-slack/issues). Take
a moment to check it hasn't been raised in the past (and possibly closed).

## Contributing

Bug [reports](https://github.com/lolcommits/lolcommits-slack/issues) and [pull
requests](https://github.com/lolcommits/lolcommits-slack/pulls) are welcome on
GitHub.

When submitting pull requests, remember to add tests covering any new behaviour,
and ensure all tests are passing on [Travis
CI](https://travis-ci.org/lolcommits/lolcommits-slack). Read the
[contributing
guidelines](https://github.com/lolcommits/lolcommits-slack/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/lolcommits/lolcommits-slack/blob/master/CODE_OF_CONDUCT.md)
for more details.

## License

The gem is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Links

* [Travis CI](https://travis-ci.org/lolcommits/lolcommits-slack)
* [Test Coverage](https://codeclimate.com/github/lolcommits/lolcommits-slack/test_coverage)
* [Code Climate](https://codeclimate.com/github/lolcommits/lolcommits-slack)
* [RDoc](http://rdoc.info/projects/lolcommits/lolcommits-slack)
* [Issues](http://github.com/lolcommits/lolcommits-slack/issues)
* [Report a bug](http://github.com/lolcommits/lolcommits-slack/issues/new)
* [Gem](http://rubygems.org/gems/lolcommits-slack)
* [GitHub](https://github.com/lolcommits/lolcommits-slack)
