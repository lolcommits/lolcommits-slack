require 'lolcommits/plugin/base'
require 'rest_client'

module Lolcommits
  module Plugin
    class Slack < Base
      ENDPOINT_URL = 'https://slack.com/api/files.upload'.freeze
      RETRY_COUNT  = 2

      ##
      # Returns the name of the plugin.
      #
      # Identifies the plugin to lolcommits.
      #
      # @return [String] the plugin name
      #
      def self.name
        'slack'
      end

      ##
      # Returns position(s) of when this plugin should run during the capture
      # process.
      #
      # The lolcommit is posted to Slack when all proccessing has completed and
      # the capture is ready.
      #
      # @return [Array] the position [:capture_ready]
      #
      def self.runner_order
        [:capture_ready]
      end

      ##
      # Capture ready hook, runs after lolcommits captures a snapshot.
      #
      # Uses `RestClient` to post the lolcommit image to (one or more) Slack
      # channels. Posting will be retried (`RETRY_COUNT`) times if any error
      # occurs.
      #
      # The post contains the git commit message, repo name and the SHA is used
      # for the image filename. The response from the POST request is sent to
      # the debug log.
      #
      def run_capture_ready
        retries = RETRY_COUNT
        begin
          response = RestClient.post(
            ENDPOINT_URL,
            file: File.new(runner.main_image),
            token: configuration['access_token'],
            filetype: 'jpg',
            filename: runner.sha,
            title: runner.message + "[#{runner.vcs_info.repo}]",
            channels: configuration['channels']
          )

          debug response
        rescue => e
          retries -= 1
          puts "Posting to Slack failed - #{e.message}"
          if retries > 0
            puts "retrying ..."
            retry
          else
            puts 'Giving up.. try running config again:'
            puts "\tlolcommits --config --p slack"
          end
        end
      end

      ##
      # Prompts the user to configure integration with Slack
      #
      # Prompts user for a Slack `access_token` and a comma seperated list of
      # valid Slack channel IDs.
      #
      # @return [Hash] a hash of configured plugin options
      #
      def configure_options!
        options = super

        if options['enabled']
          print "open the url below and issue a token for your user:\n"
          print "https://api.slack.com/custom-integrations/legacy-tokens\n"
          print "enter the generated token below, then press enter: (e.g. xxxx-xxxxxxxxx-xxxx) \n"
          code = parse_user_input(gets.strip)

          print "enter a comma-seperated list of channel ids to post images in, then press enter: (e.g. c1234567890,c1234567890)\n"
          print "note: you must use channel ids (not channel names). grab them from here; https://api.slack.com/methods/channels.list/test\n"
          channels = parse_user_input(gets.strip)

          options.merge!(
            'access_token' => code,
            'channels'     => channels
          )
        end

        options
      end

      ##
      # Returns true/false indicating if the plugin has been configured.
      #
      # Checks the `access_token` ond `channels` options have been set.
      #
      # @return [Boolean] true/false
      #
      def configured?
        !configuration['access_token'].nil? && !configuration['channels'].nil?
      end
    end
  end
end
