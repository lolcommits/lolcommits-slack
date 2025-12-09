# frozen_string_literal: true

require 'test_helper'

describe Lolcommits::Plugin::Slack do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  describe 'with a runner' do

    def runner
      # a simple lolcommits runner
      @_runner ||= Lolcommits::Runner.new(
        lolcommit_path: Tempfile.new('lolcommit.jpg')
      )
    end

    def plugin
      @_plugin ||= Lolcommits::Plugin::Slack.new(runner: runner)
    end

    def valid_enabled_config
      {
        enabled: true,
        access_token: 'acbd-1234-wxyz-5678',
        channels: 'c123,c456'
      }
    end

    describe '#run_capture_ready' do
      before do
        commit_repo_with_message
      end

      it 'should post the message to slack' do
        # Step 1: Stub getting upload URL
        stub_request(:post, plugin.class::GET_UPLOAD_URL_ENDPOINT)
          .to_return(
            status: 200,
            body: { ok: true, upload_url: "https://files.slack.com/upload/v1/ABC123", file_id: "F123ABC" }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        # Step 2: Stub file upload to Slack's upload URL
        stub_request(:post, /files\.slack\.com/)
          .to_return(status: 200, body: '')

        # Step 3: Stub completing the upload
        stub_request(:post, plugin.class::COMPLETE_UPLOAD_ENDPOINT)
          .to_return(
            status: 200,
            body: { ok: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        in_repo do
          plugin.configuration = valid_enabled_config
          output = fake_io_capture { plugin.run_capture_ready }
          assert_equal output, "Posting to Slack ... done!\n"

          # Verify Step 1: Get upload URL was called with Authorization header and correct parameters
          assert_requested :post, plugin.class::GET_UPLOAD_URL_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: 1 do |req|
              # Verify filename and length parameters are sent
              req.body.include?('filename=') && req.body.include?('length=')
            end

          # Verify Step 2: File upload was called
          assert_requested :post, /files\.slack\.com/,
            times: 1

          # Verify Step 3: Complete upload was called with correct parameters
          assert_requested :post, plugin.class::COMPLETE_UPLOAD_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: 1 do |req|
              # Verify channels and files (as JSON) parameters are sent
              req.body.include?('channels=c123%2Cc456') && req.body.include?('files=')
            end
        end
      end

      it 'should retry (and explain) if step 1 fails' do
        in_repo do
          # Stub step 1 to timeout
          stub_request(:post, plugin.class::GET_UPLOAD_URL_ENDPOINT).to_timeout

          plugin.configuration = valid_enabled_config

          _(Proc.new { plugin.run_capture_ready }).
            must_output("Posting to Slack ... failed! Timed out connecting to server\nTry running config again:\n\tlolcommits --config -p slack\n")

          # Verify Step 1 was retried RETRY_COUNT times before giving up
          assert_requested :post, plugin.class::GET_UPLOAD_URL_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: plugin.class::RETRY_COUNT
        end
      end

      it 'should retry (and explain) if step 2 fails' do
        in_repo do
          # Step 1 succeeds
          stub_request(:post, plugin.class::GET_UPLOAD_URL_ENDPOINT)
            .to_return(
              status: 200,
              body: { ok: true, upload_url: "https://files.slack.com/upload/v1/ABC123", file_id: "F123ABC" }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )

          # Step 2 times out
          stub_request(:post, /files\.slack\.com/).to_timeout

          plugin.configuration = valid_enabled_config

          _(Proc.new { plugin.run_capture_ready }).
            must_output("Posting to Slack ... failed! Timed out connecting to server\nTry running config again:\n\tlolcommits --config -p slack\n")

          # Verify Step 1 was called once
          assert_requested :post, plugin.class::GET_UPLOAD_URL_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: 1

          # Verify Step 2 was retried RETRY_COUNT times
          assert_requested :post, /files\.slack\.com/,
            times: plugin.class::RETRY_COUNT
        end
      end

      it 'should retry (and explain) if step 3 fails' do
        in_repo do
          # Step 1 succeeds
          stub_request(:post, plugin.class::GET_UPLOAD_URL_ENDPOINT)
            .to_return(
              status: 200,
              body: { ok: true, upload_url: "https://files.slack.com/upload/v1/ABC123", file_id: "F123ABC" }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )

          # Step 2 succeeds
          stub_request(:post, /files\.slack\.com/)
            .to_return(status: 200, body: '')

          # Step 3 times out
          stub_request(:post, plugin.class::COMPLETE_UPLOAD_ENDPOINT).to_timeout

          plugin.configuration = valid_enabled_config

          _(Proc.new { plugin.run_capture_ready }).
            must_output("Posting to Slack ... failed! Timed out connecting to server\nTry running config again:\n\tlolcommits --config -p slack\n")

          # Verify Step 1 was called once
          assert_requested :post, plugin.class::GET_UPLOAD_URL_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: 1

          # Verify Step 2 was called once
          assert_requested :post, /files\.slack\.com/,
            times: 1

          # Verify Step 3 was retried RETRY_COUNT times
          assert_requested :post, plugin.class::COMPLETE_UPLOAD_ENDPOINT,
            headers: { 'Authorization' => 'Bearer acbd-1234-wxyz-5678' },
            times: plugin.class::RETRY_COUNT
        end
      end

      after { teardown_repo }
    end

    describe '#enabled?' do
      it 'should be false by default' do
        _(plugin.enabled?).must_equal false
      end

      it 'should true when configured' do
        plugin.configuration = valid_enabled_config
        _(plugin.enabled?).must_equal true
      end
    end

    describe 'configuration' do
      it 'should allow plugin options to be configured' do
        configured_plugin_options = {}

        # Use .dup to create mutable strings (frozen_string_literal compatibility)
        fake_io_capture(inputs: %w(true abc-def c1,c3,c4).map(&:dup)) do
          configured_plugin_options = plugin.send(:configure_options!)
        end

        _(configured_plugin_options).must_equal({
          enabled: true,
          access_token: 'abc-def',
          channels: 'c1,c3,c4'
        })
      end

      describe '#valid_configuration?' do
        it 'should be false without config set' do
          _(plugin.valid_configuration?).must_equal(false)
        end

        it 'should be true for a valid configuration' do
          plugin.configuration = valid_enabled_config
          _(plugin.valid_configuration?).must_equal true
        end
      end
    end
  end
end
