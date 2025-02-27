class DataStore
  def initialize
    @conversations = {}
    @max_history_size = 20
  end

  def store(message_data)
    channel_id = message_data[:channel_id] || 'default'
    thread_id = message_data[:thread_id]
    
    conversation_key = build_conversation_key(channel_id, thread_id)
    
    @conversations[conversation_key] ||= []
    @conversations[conversation_key] << message_data
    
    # Trim history if it gets too long
    if @conversations[conversation_key].size > @max_history_size
      @conversations[conversation_key].shift
    end
  end

  def get_conversation(channel_id, thread_id = nil)
    conversation_key = build_conversation_key(channel_id, thread_id)
    @conversations[conversation_key] || []
  end

  def get_messages(channel_id, thread_id = nil)
    conversation = get_conversation(channel_id, thread_id)
    
    conversation.inject([]) do |acc, message|
      if message[:prompt]
        acc << {
          role: 'user',
          content: message[:prompt]
        }
      end
      if message[:response]
        acc << {
          role: 'assistant',
          content: message[:response]
        }
      end
      acc
    end
  end

  def size
    @conversations.values.sum(&:size)
  end
  
  def channel_count
    @conversations.keys.uniq { |key| key.split('::').first }.size
  end
  
  def clear_conversation(channel_id, thread_id = nil)
    conversation_key = build_conversation_key(channel_id, thread_id)
    @conversations.delete(conversation_key)
  end
  
  def all_conversations
    @conversations
  end
  
  private
  
  def build_conversation_key(channel_id, thread_id)
    thread_id ? "#{channel_id}::#{thread_id}" : channel_id.to_s
  end
end