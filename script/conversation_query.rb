#!/usr/bin/env ruby
require_relative '../config/environment'

# Simple command-line interface for ConversationQueryService
class ConversationQueryCLI
  def self.run(args)
    command = args.shift || 'help'

    case command
    when 'recent'
      limit = (args.first || 10).to_i
      ConversationQueryService.recent_messages(limit)
    when 'channel'
      channel_id = args.shift
      limit = (args.first || 10).to_i
      if channel_id
        ConversationQueryService.find_by_channel(channel_id, limit)
      else
        puts "Error: Channel ID required"
        show_help
      end
    when 'thread'
      thread_id = args.shift
      limit = (args.first || 10).to_i
      if thread_id
        ConversationQueryService.find_by_thread(thread_id, limit)
      else
        puts "Error: Thread ID required"
        show_help
      end
    when 'search'
      term = args.shift
      limit = (args.first || 10).to_i
      if term
        ConversationQueryService.find_by_content(term, limit)
      else
        puts "Error: Search term required"
        show_help
      end
    when 'stats'
      ConversationQueryService.stats
    when 'help'
      show_help
    else
      puts "Unknown command: #{command}"
      show_help
    end
  end

  def self.show_help
    puts <<~HELP
      Usage: ruby script/conversation_query.rb COMMAND [ARGS]

      Commands:
        recent [LIMIT]             - Show recent conversations (default: 10)
        channel CHANNEL_ID [LIMIT] - Show conversations for a specific channel
        thread THREAD_ID [LIMIT]   - Show conversations for a specific thread
        search TERM [LIMIT]        - Search conversations containing a term
        stats                      - Show conversation statistics
        help                       - Show this help message

      Examples:
        ruby script/conversation_query.rb recent 5
        ruby script/conversation_query.rb channel 123456789 3
        ruby script/conversation_query.rb thread 987654321
        ruby script/conversation_query.rb search "hello world"
        ruby script/conversation_query.rb stats
    HELP
  end
end

# Run the CLI with command-line arguments
ConversationQueryCLI.run(ARGV)
