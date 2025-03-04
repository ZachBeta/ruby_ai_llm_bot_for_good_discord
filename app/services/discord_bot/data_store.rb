module DiscordBot
  class DataStore
    def initialize
      Rails.logger.info "Initializing DataStore"
      @max_history_size = 20
      Rails.logger.info "Max history size: #{@max_history_size}"
      @channel_info = {}
    end

    def store(message_data)
      channel_id = message_data[:channel_id] || "default"
      thread_id = message_data[:thread_id]

      # Create a new conversation record
      Conversation.create(
        channel_id: channel_id,
        thread_id: thread_id,
        prompt: message_data[:prompt],
        response: message_data[:response],
        timestamp: message_data[:timestamp] || Time.now
      )

      # Trim history if it gets too long
      conversation_key = build_conversation_key(channel_id, thread_id)
      count = Conversation.where(channel_id: channel_id, thread_id: thread_id).count

      if count > @max_history_size
        oldest = Conversation.where(channel_id: channel_id, thread_id: thread_id)
                            .order(timestamp: :asc)
                            .first
        oldest.destroy if oldest
      end
    end

    def get_conversation(channel_id, thread_id = nil)
      Conversation.where(channel_id: channel_id, thread_id: thread_id)
                 .order(timestamp: :asc)
                 .map do |conv|
                   {
                     prompt: conv.prompt,
                     response: conv.response,
                     channel_id: conv.channel_id,
                     thread_id: conv.thread_id,
                     timestamp: conv.timestamp
                   }
                 end
    end

    def get_messages(channel_id = "default", thread_id = nil)
      conversation = get_conversation(channel_id, thread_id)
      bot_name = ENV["BOT_NAME"] || "Bot"

      conversation.inject([]) do |acc, message|
        if message[:prompt]
          acc << {
            role: "user",
            content: message[:prompt]
          }
        end
        if message[:response]
          # Ensure we're not adding the bot name prefix
          response_content = message[:response]

          acc << {
            role: "assistant",
            content: response_content
          }
        end
        acc
      end
    end

    def size
      Conversation.count
    end

    def channel_count
      Conversation.distinct.pluck(:channel_id).size
    end

    def clear_conversation(channel_id, thread_id = nil)
      Conversation.where(channel_id: channel_id, thread_id: thread_id).destroy_all
    end

    def all_conversations
      Conversation.all.group_by do |conv|
        build_conversation_key(conv.channel_id, conv.thread_id)
      end
    end

    def store_channel_info(channel_id, channel_info)
      @channel_info[channel_id.to_s] = channel_info
    end

    def get_channel_info(channel_id)
      @channel_info[channel_id.to_s]
    end

    private

    def build_conversation_key(channel_id, thread_id)
      thread_id ? "#{channel_id}::#{thread_id}" : channel_id.to_s
    end
  end
end
