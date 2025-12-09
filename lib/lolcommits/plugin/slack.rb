# frozen_string_literal: true

require 'lolcommits/plugin/base'
require 'rest_client'
require 'json'

module Lolcommits
  module Plugin
    class Slack < Base
      # Slack API endpoints
      GET_UPLOAD_URL_ENDPOINT = 'https://slack.com/api/files.getUploadURLExternal'.freeze
      COMPLETE_UPLOAD_ENDPOINT = 'https://slack.com/api/files.completeUploadExternal'.freeze

      # Number of times to retry if RestClient.post fails
      RETRY_COUNT = 2

      ##
      # Capture ready hook, runs after lolcommits captures a snapshot.
      #
      # Uses `RestClient` to post the lolcommit to (one or more) Slack
      # channels using the new 3-step upload process. Each step will be
      # retried (`RETRY_COUNT`) times if any error occurs.
      #
      # The post contains the git commit message, repo name and the SHA
      # is used for the filename. The response from the final POST
      # request is sent to the debug log.
      #
      def run_capture_ready
        print "Posting to Slack ... "

        upload_url, file_id = get_upload_url
        upload_file(upload_url)
        complete_upload(file_id)

        print "done!\n"
      rescue => e
        print "failed! #{e.message}\n"
        puts 'Try running config again:'
        puts "\tlolcommits --config -p slack"
      end

      ##
      # Prompts the user to configure integration with Slack
      #
      # Prompts user for a Slack `access_token` and a comma seperated
      # list of valid Slack channel IDs.
      #
      # @return [Hash] a hash of configured plugin options
      #
      def configure_options!
        options = super

        if options[:enabled]
          print "Open the URL below to create a new Slack app (or view existing):\n"
          print "https://api.slack.com/apps?new_app=1\n"
          print "Ensure OAuth User Token Scopes includes files:write\n"
          print "Install the app to your Slack workspace\n"
          print "Paste the app's User OAuth Token below: (e.g. xxxx-xxxxxxxxx-xxxx)\n"
          code = parse_user_input(gets.strip)

          print "Enter a comma-seperated list of channel IDs to post into: (e.g. C0FPKDOJJ,C0APK3PPK)\n"
          print "Note: you must use channel IDs (not names). Right-click channel -> View Channel Details -> look for a Channel ID\n"
          channels = parse_user_input(gets.strip)

          options.merge!(
            access_token: code,
            channels: channels
          )
        end

        options
      end

      private

      ##
      # Step 1: Get upload URL from Slack
      #
      # @return [Array<String>] upload_url and file_id
      #
      def get_upload_url
        retries = RETRY_COUNT
        begin
          response = RestClient.post(
            GET_UPLOAD_URL_ENDPOINT,
            {
              filename: runner.sha,
              length: File.size(runner.lolcommit_path)
            },
            {
              Authorization: "Bearer #{configuration[:access_token]}"
            }
          )

          result = JSON.parse(response.body)
          debug "Step 1 response: #{result}"

          unless result['ok']
            raise "Slack API error: #{result['error']}"
          end

          [result['upload_url'], result['file_id']]
        rescue => e
          retries -= 1
          if retries > 0
            retry
          else
            raise e
          end
        end
      end

      ##
      # Step 2: Upload file binary to the upload URL
      #
      # @param upload_url [String] the upload URL from step 1
      #
      def upload_file(upload_url)
        retries = RETRY_COUNT
        begin
          RestClient.post(
            upload_url,
            {
              file: File.new(runner.lolcommit_path)
            }
          )

          debug "Step 2: File uploaded successfully"
        rescue => e
          retries -= 1
          if retries > 0
            retry
          else
            raise e
          end
        end
      end

      ##
      # Step 3: Complete the upload and share to channels
      #
      # @param file_id [String] the file_id from step 1
      #
      def complete_upload(file_id)
        retries = RETRY_COUNT
        begin
          title = runner.message + "[#{runner.vcs_info.repo}]"
          files_json = JSON.generate([{ id: file_id, title: title }])

          response = RestClient.post(
            COMPLETE_UPLOAD_ENDPOINT,
            {
              files: files_json,
              channels: configuration[:channels]
            },
            {
              Authorization: "Bearer #{configuration[:access_token]}"
            }
          )

          result = JSON.parse(response.body)
          debug "Step 3 response: #{result}"

          unless result['ok']
            raise "Slack API error: #{result['error']}"
          end
        rescue => e
          retries -= 1
          if retries > 0
            retry
          else
            raise e
          end
        end
      end

    end
  end
end
