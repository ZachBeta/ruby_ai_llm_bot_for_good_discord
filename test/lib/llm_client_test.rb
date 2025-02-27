require_relative '../test_helper'

class LlmClientTest < Minitest::Test
  def setup
    @llm_client = LlmClient.new
    
    # Add a stub for the LLM API
    stub_request(:post, "https://openrouter.ai/api/v1/chat/completions").
      to_return(
        status: 200,
        body: {
          choices: [
            {
              message: {
                content: "This is a test response"
              }
            }
          ]
        }.to_json,
        headers: {'Content-Type' => 'application/json'}
      )
  end

  def test_generate_response_stores_prompt_in_data_store
    prompt = "Test prompt"
    channel_id = "test_channel"
    thread_id = "test_thread"
    
    @llm_client.data_store.expects(:store).with(
      has_entries(prompt: prompt, channel_id: channel_id, thread_id: thread_id)
    ).once
    
    # Mock the rest of the process to avoid API call
    @llm_client.expects(:build_messages).returns([])
    @llm_client.expects(:make_request).returns("Test response")
    @llm_client.data_store.expects(:store).with(
      has_entries(response: "Test response", channel_id: channel_id, thread_id: thread_id)
    ).once
    
    @llm_client.generate_response(prompt, channel_id, thread_id)
  end

  def test_build_messages_includes_system_prompt_and_history
    channel_id = "test_channel"
    thread_id = "test_thread"
    prompt = "Test prompt"
    
    # Setup history in data store
    history_messages = [
      { role: 'user', content: 'Previous question' },
      { role: 'assistant', content: 'Previous answer' }
    ]
    
    @llm_client.data_store.expects(:get_messages).with(channel_id, thread_id).returns(history_messages)
    
    messages = @llm_client.send(:build_messages, channel_id, thread_id, prompt)
    
    assert_equal 'system', messages.first[:role]
    assert_includes messages.first[:content], "helpful assistant"
    assert_equal history_messages, messages[1..-1]
  end

  def test_make_request_sends_correct_api_request
    messages = [
      { role: 'system', content: 'You are a helpful assistant. You answer short and concise.' },
      { role: 'user', content: 'What is Ruby?' }
    ]
    
    response = @llm_client.send(:make_request, messages)
    
    assert_equal "This is a test response", response
  end

  def test_api_error_handling
    # We'll directly mock the implementation rather than using expectations
    # to avoid issues with the real method being called
    messages = [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Test message' }
    ]
    
    error_body = {
      error: "API error",
      choices: [
        {
          message: {
            content: "Error occurred"
          }
        }
      ]
    }.to_json
    
    # Override the default stub with an error response
    stub_request(:post, "https://openrouter.ai/api/v1/chat/completions").
      to_return(
        status: 422,
        body: error_body,
        headers: {'Content-Type' => 'application/json'}
      )
    
    response = @llm_client.send(:make_request, messages)
    assert_equal "Error occurred", response
  end

  def test_generate_response_integration
    response = @llm_client.generate_response("What is Ruby?", "test_channel", nil)
    
    assert_equal "This is a test response", response
    
    # Verify data was stored
    messages = @llm_client.data_store.get_messages("test_channel")
    assert_equal 2, messages.size
    assert_equal "user", messages.first[:role]
    assert_equal "What is Ruby?", messages.first[:content]
    assert_equal "assistant", messages.last[:role]
    assert_equal response, messages.last[:content]
  end

  def test_parse_response_handles_json_parse_error
    response_mock = mock()
    response_mock.stubs(:is_a?).with(Net::HTTPSuccess).returns(true)
    response_mock.stubs(:body).returns('invalid json')
    
    result = @llm_client.send(:parse_response, response_mock)
    
    assert_equal 'Error parsing LLM response', result
  end

  def test_parse_response_handles_unsuccessful_http_response
    response_mock = mock()
    response_mock.stubs(:is_a?).with(Net::HTTPSuccess).returns(false)
    
    result = @llm_client.send(:parse_response, response_mock)
    
    assert_equal 'Error communicating with LLM', result
  end
end 