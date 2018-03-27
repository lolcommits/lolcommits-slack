require 'test_helper'

describe Lolcommits::Plugin::Slack do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  describe 'with a runner' do

    def runner
      # a simple lolcommits runner
      @_runner ||= Lolcommits::Runner.new(
        main_image: Tempfile.new('test_image')
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
        stub_request(:any, plugin.class::ENDPOINT_URL)
        in_repo do
          plugin.configuration = valid_enabled_config
          output = fake_io_capture { plugin.run_capture_ready }
          assert_equal output, "Posting to Slack ... done!\n"

          assert_requested :post, plugin.class::ENDPOINT_URL,
            headers: { 'Content-Type' => /multipart\/form-data;/ },
            times: 1
        end
      end

      it 'should retry (and explain) if there is a failure (req timeout)' do
        in_repo do
          stub_request(:any, plugin.class::ENDPOINT_URL).to_timeout
          plugin.configuration = valid_enabled_config

          Proc.new { plugin.run_capture_ready }.
            must_output("Posting to Slack ... failed! Timed out connecting to server - retrying ...\nPosting to Slack ... failed! Timed out connecting to server - giving up ...\nTry running config again:\n\tlolcommits --config -p slack\n")

          assert_requested :post, plugin.class::ENDPOINT_URL,
            headers: { 'Content-Type' => /multipart\/form-data;/ },
            times: plugin.class::RETRY_COUNT
        end
      end

      after { teardown_repo }
    end

    describe '#enabled?' do
      it 'should be false by default' do
        plugin.enabled?.must_equal false
      end

      it 'should true when configured' do
        plugin.configuration = valid_enabled_config
        plugin.enabled?.must_equal true
      end
    end

    describe 'configuration' do
      it 'should allow plugin options to be configured' do
        configured_plugin_options = {}

        fake_io_capture(inputs: %w(true abc-def c1,c3,c4)) do
          configured_plugin_options = plugin.configure_options!
        end

        configured_plugin_options.must_equal({
          enabled: true,
          access_token: 'abc-def',
          channels: 'c1,c3,c4'
        })
      end

      describe '#valid_configuration?' do
        it 'should be false without config set' do
          plugin.valid_configuration?.must_equal(false)
        end

        it 'should be true for a valid configuration' do
          plugin.configuration = valid_enabled_config
          plugin.valid_configuration?.must_equal true
        end
      end
    end
  end
end
