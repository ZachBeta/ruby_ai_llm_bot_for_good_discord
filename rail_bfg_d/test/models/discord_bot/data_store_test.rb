require "test_helper"

class DiscordBot::DataStoreTest < ActiveSupport::TestCase
  setup do
    @data_store = DiscordBot::DataStore.new
    # Clear any existing conversations before each test
    Conversation.destroy_all
  end

  test "store and retrieve conversation" do
    test_message = {
      channel_id: 'test_channel',
      thread_id: nil,
      prompt: 'Test prompt',
      response: 'Test response',
      timestamp: Time.now
    }
    
    assert_equal 0, @data_store.size, "Initial conversation count should be 0"
    
    @data_store.store(test_message)
    assert_equal 1, @data_store.size, "After storing message, conversation count should be 1"
    
    conversation = @data_store.get_conversation('test_channel')
    assert_equal 1, conversation.size, "Should retrieve one conversation entry"
    assert_equal 'Test prompt', conversation.first[:prompt], "Should retrieve correct prompt"
    assert_equal 'Test response', conversation.first[:response], "Should retrieve correct response"
    assert_equal 'test_channel', conversation.first[:channel_id], "Should retrieve correct channel_id"
    assert_nil conversation.first[:thread_id], "Thread ID should be nil"
  end

  test "clear conversation" do
    test_message = {
      channel_id: 'test_channel',
      thread_id: nil,
      prompt: 'Test prompt',
      response: 'Test response',
      timestamp: Time.now
    }
    
    @data_store.store(test_message)
    assert_equal 1, @data_store.size, "After storing message, conversation count should be 1"
    
    @data_store.clear_conversation('test_channel')
    assert_equal 0, @data_store.size, "After clearing, conversation count should be 0"
  end

  test "get_messages formats conversation correctly" do
    test_message = {
      channel_id: 'test_channel',
      thread_id: nil,
      prompt: 'Test prompt',
      response: 'Test response',
      timestamp: Time.now
    }
    
    @data_store.store(test_message)
    
    messages = @data_store.get_messages('test_channel')
    assert_equal 2, messages.size, "Should have two messages (user and assistant)"
    
    assert_equal 'user', messages.first[:role], "First message should be from user"
    assert_equal 'Test prompt', messages.first[:content], "First message should have correct content"
    
    assert_equal 'assistant', messages.last[:role], "Second message should be from assistant"
    assert_equal 'Test response', messages.last[:content], "Second message should have correct content"
  end

  test "all_conversations groups by channel and thread" do
    test_message1 = {
      channel_id: 'test_channel1',
      thread_id: nil,
      prompt: 'Test prompt 1',
      response: 'Test response 1',
      timestamp: Time.now
    }
    
    test_message2 = {
      channel_id: 'test_channel2',
      thread_id: 'thread1',
      prompt: 'Test prompt 2',
      response: 'Test response 2',
      timestamp: Time.now
    }
    
    @data_store.store(test_message1)
    @data_store.store(test_message2)
    
    all_convs = @data_store.all_conversations
    assert_equal 2, all_convs.keys.size, "Should have two conversation keys"
    assert all_convs.keys.include?("test_channel1"), "Should include test_channel1"
    assert all_convs.keys.include?("test_channel2::thread1"), "Should include test_channel2::thread1"
  end

  test "channel_count returns correct number of unique channels" do
    test_message1 = {
      channel_id: 'test_channel1',
      thread_id: nil,
      prompt: 'Test prompt 1',
      response: 'Test response 1',
      timestamp: Time.now
    }
    
    test_message2 = {
      channel_id: 'test_channel2',
      thread_id: 'thread1',
      prompt: 'Test prompt 2',
      response: 'Test response 2',
      timestamp: Time.now
    }
    
    test_message3 = {
      channel_id: 'test_channel1',
      thread_id: 'thread2',
      prompt: 'Test prompt 3',
      response: 'Test response 3',
      timestamp: Time.now
    }
    
    @data_store.store(test_message1)
    @data_store.store(test_message2)
    @data_store.store(test_message3)
    
    assert_equal 2, @data_store.channel_count, "Should have 2 unique channels"
  end

  test "max history size is enforced" do
    # Set a small max_history_size for testing
    @data_store.instance_variable_set(:@max_history_size, 2)
    
    # Add 3 messages to the same channel
    3.times do |i|
      @data_store.store({
        channel_id: 'test_channel',
        thread_id: nil,
        prompt: "Test prompt #{i}",
        response: "Test response #{i}",
        timestamp: Time.now + i.seconds
      })
    end
    
    # Should only keep the 2 most recent messages
    conversation = @data_store.get_conversation('test_channel')
    assert_equal 2, conversation.size, "Should only keep max_history_size messages"
    
    # The oldest message should be removed
    prompts = conversation.map { |msg| msg[:prompt] }
    assert_not prompts.include?("Test prompt 0"), "Oldest message should be removed"
    assert prompts.include?("Test prompt 1"), "Second message should be kept"
    assert prompts.include?("Test prompt 2"), "Newest message should be kept"
  end
end
