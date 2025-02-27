require 'minitest/autorun'
require 'minitest/pride'
require 'dotenv/load'
require 'vcr'
require 'webmock/minitest'
require 'mocha/api'
require 'mocha/minitest'

# Ensure we're in test environment
ENV['RACK_ENV'] = ENV['ENVIRONMENT'] = 'test'
# Set a test flag to prevent sending actual Discord messages
ENV['TESTING'] = 'true'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require_relative '../lib/llm_client'
require_relative '../lib/data_store'
require_relative '../bot'
# require_relative '../bot' 

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.filter_sensitive_data('<OPENROUTER_API_KEY>') { ENV['OPENROUTER_API_KEY'] }
  config.filter_sensitive_data('<DISCORD_TOKEN>') { ENV['DISCORD_TOKEN'] }
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: [:method, :uri, :body]
  }
end

# Allow certain Discord API operations in tests
WebMock.disable_net_connect!(allow_localhost: true)

class Minitest::Test
  include WebMock::API
  
  def setup
    # Reset environment before each test
    
    # Add a stub for Discord API calls
    stub_request(:post, /discord\.com\/api\/v9\/channels\/.*\/messages/).
      to_return(status: 200, body: '{"id":"123456789","content":"Test message"}', headers: {'Content-Type' => 'application/json'})
  end

  def teardown
    # Clean up after each test
    WebMock.reset!
  end
end
