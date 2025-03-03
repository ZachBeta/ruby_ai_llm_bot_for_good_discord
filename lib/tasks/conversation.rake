namespace :conversation do
  desc "Show recent conversations (usage: rake conversation:recent[limit])"
  task :recent, [:limit] => :environment do |_, args|
    limit = (args[:limit] || 10).to_i
    ConversationQueryService.recent_messages(limit)
  end
  
  desc "Show conversations for a specific channel (usage: rake conversation:channel[channel_id,limit])"
  task :channel, [:channel_id, :limit] => :environment do |_, args|
    channel_id = args[:channel_id]
    limit = (args[:limit] || 10).to_i
    
    if channel_id
      ConversationQueryService.find_by_channel(channel_id, limit)
    else
      puts "Error: Channel ID required"
      puts "Usage: rake conversation:channel[channel_id,limit]"
    end
  end
  
  desc "Show conversations for a specific thread (usage: rake conversation:thread[thread_id,limit])"
  task :thread, [:thread_id, :limit] => :environment do |_, args|
    thread_id = args[:thread_id]
    limit = (args[:limit] || 10).to_i
    
    if thread_id
      ConversationQueryService.find_by_thread(thread_id, limit)
    else
      puts "Error: Thread ID required"
      puts "Usage: rake conversation:thread[thread_id,limit]"
    end
  end
  
  desc "Search conversations containing a term (usage: rake conversation:search[term,limit])"
  task :search, [:term, :limit] => :environment do |_, args|
    term = args[:term]
    limit = (args[:limit] || 10).to_i
    
    if term
      ConversationQueryService.find_by_content(term, limit)
    else
      puts "Error: Search term required"
      puts "Usage: rake conversation:search[term,limit]"
    end
  end
  
  desc "Show conversation statistics"
  task stats: :environment do
    ConversationQueryService.stats
  end
end 