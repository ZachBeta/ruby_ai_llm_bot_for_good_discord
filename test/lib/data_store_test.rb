require_relative '../test_helper'

class DataStoreTest < Minitest::Test
  def setup
    @data_store = DataStore.new
  end

  def test_store_adds_message_to_conversation
    @data_store.store(prompt: "Hello", channel_id: "123", thread_id: nil, timestamp: Time.now)
    conversation = @data_store.get_conversation("123")
    
    assert_equal 1, conversation.size
    assert_equal "Hello", conversation.first[:prompt]
  end

  def test_get_conversation_returns_empty_array_for_nonexistent_conversation
    conversation = @data_store.get_conversation("nonexistent")
    assert_equal [], conversation
  end

  def test_get_messages_formats_conversation_correctly
    time = Time.now
    @data_store.store(prompt: "User message", channel_id: "123", timestamp: time)
    @data_store.store(response: "Bot response", channel_id: "123", timestamp: time)
    
    messages = @data_store.get_messages("123")
    
    assert_equal 2, messages.size
    assert_equal "user", messages.first[:role]
    assert_equal "User message", messages.first[:content]
    assert_equal "assistant", messages.last[:role]
    assert_equal "Bot response", messages.last[:content]
  end

  def test_size_returns_total_message_count
    @data_store.store(prompt: "Message 1", channel_id: "123", timestamp: Time.now)
    @data_store.store(response: "Response 1", channel_id: "123", timestamp: Time.now)
    @data_store.store(prompt: "Message 2", channel_id: "456", timestamp: Time.now)
    
    assert_equal 3, @data_store.size
  end

  def test_channel_count_returns_number_of_unique_channels
    @data_store.store(prompt: "Message 1", channel_id: "123", timestamp: Time.now)
    @data_store.store(prompt: "Message 2", channel_id: "123", thread_id: "thread1", timestamp: Time.now)
    @data_store.store(prompt: "Message 3", channel_id: "456", timestamp: Time.now)
    
    assert_equal 2, @data_store.channel_count
  end

  def test_clear_conversation_removes_conversation
    @data_store.store(prompt: "Message", channel_id: "123", timestamp: Time.now)
    @data_store.clear_conversation("123")
    
    assert_equal [], @data_store.get_conversation("123")
  end

  def test_clear_conversation_with_thread_removes_only_that_thread
    @data_store.store(prompt: "Channel message", channel_id: "123", timestamp: Time.now)
    @data_store.store(prompt: "Thread message", channel_id: "123", thread_id: "thread1", timestamp: Time.now)
    
    @data_store.clear_conversation("123", "thread1")
    
    assert_equal 1, @data_store.get_conversation("123").size
    assert_equal "Channel message", @data_store.get_conversation("123").first[:prompt]
    assert_equal [], @data_store.get_conversation("123", "thread1")
  end

  def test_all_conversations_returns_full_conversation_hash
    @data_store.store(prompt: "Message 1", channel_id: "123", timestamp: Time.now)
    @data_store.store(prompt: "Message 2", channel_id: "456", timestamp: Time.now)
    
    conversations = @data_store.all_conversations
    
    assert_equal 2, conversations.keys.size
    assert conversations.key?("123")
    assert conversations.key?("456")
  end

  def test_history_is_trimmed_when_exceeding_max_size
    store = DataStore.new
    # Access private @max_history_size
    max_size = store.instance_variable_get(:@max_history_size)
    
    (max_size + 5).times do |i|
      store.store(prompt: "Message #{i}", channel_id: "123", timestamp: Time.now)
    end
    
    conversation = store.get_conversation("123")
    assert_equal max_size, conversation.size
    assert_equal "Message 5", conversation.first[:prompt]
  end
end
