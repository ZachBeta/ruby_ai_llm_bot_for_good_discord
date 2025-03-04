require "pp"

class ConversationQueryService
  def self.recent_messages(limit = 10)
    conversations = Conversation.order(created_at: :desc).limit(limit)

    puts "\n=== #{limit} Most Recent Conversations ===\n\n"
    conversations.each_with_index do |conversation, index|
      puts "Conversation ##{index + 1} (ID: #{conversation.id})"
      puts "Channel: #{conversation.channel_id}, Thread: #{conversation.thread_id}"
      puts "Created at: #{conversation.created_at}"
      puts "Updated at: #{conversation.updated_at}"
      puts "\nPrompt:"
      pp conversation.prompt
      puts "\nResponse:"
      pp conversation.response
      puts "\n" + "-" * 80 + "\n\n"
    end

    conversations
  end

  def self.find_by_channel(channel_id, limit = 10)
    conversations = Conversation.where(channel_id: channel_id)
                               .order(created_at: :desc)
                               .limit(limit)

    puts "\n=== #{conversations.size} Conversations for Channel #{channel_id} ===\n\n"
    pretty_print_conversations(conversations)

    conversations
  end

  def self.find_by_thread(thread_id, limit = 10)
    conversations = Conversation.where(thread_id: thread_id)
                               .order(created_at: :desc)
                               .limit(limit)

    puts "\n=== #{conversations.size} Conversations for Thread #{thread_id} ===\n\n"
    pretty_print_conversations(conversations)

    conversations
  end

  def self.find_by_content(search_term, limit = 10)
    conversations = Conversation.where("prompt LIKE ? OR response LIKE ?",
                                     "%#{search_term}%",
                                     "%#{search_term}%")
                               .order(created_at: :desc)
                               .limit(limit)

    puts "\n=== #{conversations.size} Conversations containing '#{search_term}' ===\n\n"
    pretty_print_conversations(conversations)

    conversations
  end

  def self.stats
    total = Conversation.count
    channels = Conversation.distinct.pluck(:channel_id).size
    threads = Conversation.distinct.pluck(:thread_id).size
    oldest = Conversation.minimum(:created_at)
    newest = Conversation.maximum(:created_at)

    puts "\n=== Conversation Statistics ===\n\n"
    puts "Total conversations: #{total}"
    puts "Unique channels: #{channels}"
    puts "Unique threads: #{threads}"
    puts "Oldest conversation: #{oldest}"
    puts "Newest conversation: #{newest}"
    puts "\n"

    {
      total: total,
      channels: channels,
      threads: threads,
      oldest: oldest,
      newest: newest
    }
  end

  private

  def self.pretty_print_conversations(conversations)
    if conversations.empty?
      puts "No conversations found."
      return
    end

    conversations.each_with_index do |conversation, index|
      puts "Conversation ##{index + 1} (ID: #{conversation.id})"
      puts "Channel: #{conversation.channel_id}, Thread: #{conversation.thread_id}"
      puts "Created at: #{conversation.created_at}"
      puts "Updated at: #{conversation.updated_at}"
      puts "\nPrompt:"
      pp conversation.prompt
      puts "\nResponse:"
      pp conversation.response
      puts "\n" + "-" * 80 + "\n\n"
    end
  end
end
