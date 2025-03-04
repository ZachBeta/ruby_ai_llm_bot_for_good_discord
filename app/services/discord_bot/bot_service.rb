module DiscordBot
  class BotService
    def initialize
      Rails.logger.info "Initializing Discord bot..."
      @token = ENV["DISCORD_TOKEN"]
      Rails.logger.info "DISCORD_TOKEN: #{@token[0..5]}...#{@token[-5..-1]}"
      @bot = Discordrb::Bot.new(token: @token)
      Rails.logger.info "Discord bot initialized."
      @llm = LlmClient.new
      @prompt_service = PromptService.new
      Rails.logger.info "LLM client initialized."

      # Set the bot's name in the environment variables
      ENV["BOT_NAME"] = @bot.profile.name
      Rails.logger.info "Bot name set to: #{ENV["BOT_NAME"]}"

      # Store start time for uptime calculation
      @start_time = Time.now
      Rails.logger.info "Bot start time recorded: #{@start_time}"

      setup_commands
      Rails.logger.info "Commands setup."
      send_to_channel(ENV["DISCORD_CHANNEL_ID"], "Restarted\n#{Time.now.iso8601(9)}\n#{ENV['BOT_STRING']}")

      Rails.logger.info "Discord bot setup complete."
    end

    def start
      @bot.run
    end

    def send_to_channel(channel_id, message)
      Rails.logger.info "Sending message to channel #{channel_id}: #{message}"
      @bot.send_message(channel_id, message)
    end

    private

    def setup_commands
      setup_debug_command
      setup_clear_command
      setup_prompt_commands
      setup_help_command
      setup_language_practice_command
      setup_message_handler
    end

    def setup_debug_command
      @bot.message do |event|
        next unless event.content.start_with?("!debug")
        Rails.logger.info "!debug command received"
        channel_id = event.channel.id
        Rails.logger.info "Channel ID: #{channel_id}"

        # Safely get thread_id with error handling
        thread_id = nil
        begin
          Rails.logger.info "Checking if message has thread attribute: #{event.message.respond_to?(:thread)}"

          # Check if the channel is a thread type (type 11 in Discord API)
          is_thread_channel = false
          thread_name = "N/A"

          if event.message.respond_to?(:channel) && event.message.channel.respond_to?(:type)
            channel_type = event.message.channel.type
            Rails.logger.info "Message channel type: #{channel_type}"

            # Discord channel types: 11 = public thread, 12 = private thread
            if [ 11, 12 ].include?(channel_type)
              is_thread_channel = true
              thread_id = event.channel.id
              thread_name = event.channel.name
              Rails.logger.info "Thread detected via channel type: ID=#{thread_id}, Name=#{thread_name}"
            end
          end

          # Fallback to traditional thread detection if needed
          if !is_thread_channel && event.message.respond_to?(:thread)
            thread_id = event.message.thread&.id
            Rails.logger.info "Thread ID from event.message.thread&.id: #{thread_id.inspect}"
          end

          # Additional thread detection methods for debugging
          Rails.logger.info "Event class: #{event.class}"
          Rails.logger.info "Message class: #{event.message.class}"
          Rails.logger.info "Message attributes: #{event.message.instance_variables.map(&:to_s).join(', ')}"

          if event.message.respond_to?(:channel)
            Rails.logger.info "Message channel class: #{event.message.channel.class}"
            Rails.logger.info "Message channel type: #{event.message.channel.type}" if event.message.channel.respond_to?(:type)
          end
        rescue => e
          Rails.logger.error "Error getting thread ID: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end

        # Basic stats
        channel_count = @llm.data_store.channel_count
        total_message_count = @llm.data_store.size

        # Get thread count
        thread_count = Conversation.distinct.pluck(:thread_id).compact.size

        # Get prompt stats
        prompt_count = Prompt.count
        default_prompt = @prompt_service.find_by_name("default")
        default_prompt_name = default_prompt ? "default (#{default_prompt.content[0..30]}...)" : "None (using fallback)"

        # Get conversation stats for current channel/thread
        current_channel_count = Conversation.where(channel_id: channel_id).count
        current_thread_count = thread_id ? Conversation.where(channel_id: channel_id, thread_id: thread_id).count : 0

        # Get time stats
        oldest_message = Conversation.minimum(:created_at)
        newest_message = Conversation.maximum(:created_at)

        # Get uptime with error handling
        uptime_str = "Unknown"
        begin
          uptime = Time.now - @start_time

          # Format uptime nicely
          days = (uptime / 86400).floor
          hours = ((uptime % 86400) / 3600).floor
          minutes = ((uptime % 3600) / 60).floor
          seconds = (uptime % 60).floor
          uptime_str = "#{days}d #{hours}h #{minutes}m #{seconds}s"
        rescue => e
          Rails.logger.error "Error calculating uptime: #{e.message}"
        end

        # Determine if we're in a thread
        in_thread = false
        begin
          # Check if the message is in a thread
          if thread_id
            in_thread = true
            Rails.logger.info "In thread: #{in_thread}, Thread name: #{thread_name}"
          else
            Rails.logger.info "Not in a thread (thread_id is nil)"
          end
        rescue => e
          Rails.logger.error "Error determining thread status: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end

        response = <<~STR
          **Bot Status**
          Using model: #{ENV['BOT_STRING']}
          Bot uptime: #{uptime_str}

          **Conversation Stats**
          Total messages: #{total_message_count}
          Active channels: #{channel_count}
          Active threads: #{thread_count}

          **Current Context**
          Channel messages: #{current_channel_count}
          #{in_thread ? "Thread: #{thread_name} (#{current_thread_count} messages)" : "Not in a thread"}

          **Prompt System**
          Total prompts: #{prompt_count}
          Default prompt: #{default_prompt_name}

          **Time Range**
          Oldest message: #{oldest_message ? oldest_message.strftime("%Y-%m-%d %H:%M:%S") : "None"}
          Newest message: #{newest_message ? newest_message.strftime("%Y-%m-%d %H:%M:%S") : "None"}
        STR
        event.respond response
      end
    end

    def setup_clear_command
      @bot.message do |event|
        next unless event.content.start_with?("!clear")
        Rails.logger.info "!clear command received"
        channel_id = event.channel.id

        # Safely get thread_id with error handling
        thread_id = nil
        begin
          thread_id = event.message.thread&.id if event.message.respond_to?(:thread)
        rescue => e
          Rails.logger.error "Error getting thread ID: #{e.message}"
        end

        @llm.data_store.clear_conversation(channel_id, thread_id)
        event.respond "Conversation history cleared for this #{thread_id ? 'thread' : 'channel'}."
      end
    end

    def setup_prompt_commands
      # List all prompts
      @bot.message do |event|
        next unless event.content.start_with?("!prompts")
        Rails.logger.info "!prompts command received"
        prompts = @prompt_service.all

        if prompts.empty?
          event.respond "No prompts found."
        else
          response = "Available prompts:\n"
          prompts.each do |prompt|
            response += "- #{prompt.name}\n"
          end
          event.respond response
        end
      end

      # Create or update a prompt
      @bot.message do |event|
        next unless event.content.start_with?("!prompt set")
        Rails.logger.info "!prompt set command received"
        content = event.content.sub("!prompt set", "").strip

        # Extract name and content
        match = content.match(/^(\S+)\s+(.+)$/m)
        if match
          name = match[1]
          prompt_content = match[2]

          prompt = @prompt_service.find_by_name(name)
          if prompt
            @prompt_service.update(name, prompt_content)
            event.respond "Prompt '#{name}' updated."
          else
            @prompt_service.create(name, prompt_content)
            event.respond "Prompt '#{name}' created."
          end
        else
          event.respond "Invalid format. Use: !prompt set [name] [content]"
        end
      end

      # Get a prompt
      @bot.message do |event|
        next unless event.content.start_with?("!prompt get")
        Rails.logger.info "!prompt get command received"
        name = event.content.sub("!prompt get", "").strip

        prompt = @prompt_service.find_by_name(name)
        if prompt
          event.respond "Prompt '#{name}':\n```\n#{prompt.content}\n```"
        else
          event.respond "Prompt '#{name}' not found."
        end
      end

      # Delete a prompt
      @bot.message do |event|
        next unless event.content.start_with?("!prompt delete")
        Rails.logger.info "!prompt delete command received"
        name = event.content.sub("!prompt delete", "").strip

        if @prompt_service.delete(name)
          event.respond "Prompt '#{name}' deleted."
        else
          event.respond "Prompt '#{name}' not found."
        end
      end

      # Set default prompt
      @bot.message do |event|
        next unless event.content.start_with?("!prompt default")
        Rails.logger.info "!prompt default command received"
        name = event.content.sub("!prompt default", "").strip

        prompt = @prompt_service.find_by_name(name)
        if prompt
          default_prompt = @prompt_service.find_by_name("default")
          if default_prompt
            @prompt_service.update("default", prompt.content)
          else
            @prompt_service.create("default", prompt.content)
          end
          event.respond "Default prompt set to '#{name}'."
        else
          event.respond "Prompt '#{name}' not found."
        end
      end
    end

    def setup_help_command
      @bot.message do |event|
        next unless event.content.start_with?("!help")
        Rails.logger.info "!help command received"

        help_text = <<~HELP
          **Available Commands:**

          **General Commands:**
          `!help` - Display this help message
          `!clear` - Clear conversation history for this channel/thread
          `!debug` - Show debug information about the bot

          **Prompt Management:**
          `!prompts` - List all available prompts
          `!prompt set [name] [content]` - Create or update a prompt
          `!prompt get [name]` - Display the content of a prompt
          `!prompt delete [name]` - Delete a prompt
          `!prompt default [name]` - Set a prompt as the default system prompt

          **Language Practice:**
          `!language` - Show language practice commands
          `!language init` - Initialize default language practice prompts
          `!language list` - List available language practice prompts
          `!language detect [text]` - Detect language from channel name or provided text

          **Conversation:**
          Just mention the bot or send a message in an allowed channel to start a conversation.
          You can also include commands anywhere in your message.
        HELP

        event.respond help_text
      end
    end

    def setup_language_practice_command
      @bot.message do |event|
        next unless event.content.start_with?("!language")
        Rails.logger.info "!language command received"
        
        command_parts = event.content.split(" ")
        subcommand = command_parts[1]&.downcase
        
        language_prompt_service = LanguagePromptService.new(@prompt_service)
        
        case subcommand
        when "init"
          # Initialize default language practice prompts
          language_prompt_service.create_default_prompts
          event.respond "Language practice prompts initialized."
        when "list"
          # List available language prompts
          prompts = @prompt_service.all.select { |p| p.name.start_with?("language_practice_") }
          
          if prompts.empty?
            event.respond "No language practice prompts found. Use `!language init` to create default prompts."
          else
            response = "Available language practice prompts:\n"
            prompts.each do |prompt|
              response += "- #{prompt.name}\n"
            end
            event.respond response
          end
        when "detect"
          # Detect language from channel name or message
          channel_name = event.channel.name
          message_content = command_parts[2..-1]&.join(" ")
          
          language_code = language_prompt_service.detect_language(channel_name, message_content)
          
          if language_code
            language_name = LanguagePromptService::SUPPORTED_LANGUAGES.key(language_code)
            event.respond "Detected language: #{language_name} (#{language_code})"
          else
            event.respond "No language detected from channel name or message."
          end
        else
          # Show help for language commands
          help_text = <<~HELP
            **Language Practice Commands:**
            `!language init` - Initialize default language practice prompts
            `!language list` - List available language practice prompts
            `!language detect [text]` - Detect language from channel name or provided text
          HELP
          
          event.respond help_text
        end
      end
    end

    def setup_message_handler
      @bot.message do |event|
        Rails.logger.info "Message received"
        # Skip if the message contains a command
        next if event.content.start_with?("!debug") ||
                event.content.start_with?("!clear") ||
                event.content.start_with?("!prompts") ||
                event.content.start_with?("!prompt") ||
                event.content.start_with?("!help") ||
                event.content.start_with?("!language")

        # Get allowed channels from env (comma-separated list of channel IDs)
        allowed_channels = ENV["BOT_ALLOWED_CHANNELS"]&.split(",")&.map(&:strip) || []

        # Check if the message is a reply to one of the bot's messages
        is_reply_to_bot = false
        begin
          if event.message.respond_to?(:referenced_message) && event.message.referenced_message
            referenced_message = event.message.referenced_message
            is_reply_to_bot = referenced_message.author.id == @bot.profile.id
          end
        rescue => e
          Rails.logger.error "Error checking if message is a reply to bot: #{e.message}"
        end

        # Skip if the bot isn't mentioned, not in an allowed channel, and not a reply to the bot
        bot_mentioned = event.content.include?("<@#{@bot.profile.id}>") ||
                        event.content.include?("<@!#{@bot.profile.id}>")
        is_allowed_channel = allowed_channels.include?(event.channel.id.to_s)

        next unless bot_mentioned || is_allowed_channel || is_reply_to_bot

        Rails.logger.info "=== Mention Event Details ==="
        Rails.logger.info "Channel ID: #{event.channel.id}"
        Rails.logger.info "Channel Name: #{event.channel.name}"
        Rails.logger.info "Server ID: #{event.server&.id}"
        Rails.logger.info "Server Name: #{event.server&.name}"
        Rails.logger.info "Message ID: #{event.message.id}"
        Rails.logger.info "Content: #{event.content}"
        Rails.logger.info "Author ID: #{event.user.id}"
        Rails.logger.info "Author Name: #{event.user.name}"
        Rails.logger.info "Timestamp: #{event.timestamp}"
        Rails.logger.info "Bot ID: #{@bot.profile.id}"
        Rails.logger.info "Bot Name: #{@bot.profile.name}"
        Rails.logger.info "Is Reply To Bot: #{is_reply_to_bot}"
        Rails.logger.info "=========================="

        channel_id = event.channel.id
        
        # Store channel information for language detection
        @llm.data_store.store_channel_info(channel_id, {
          name: event.channel.name,
          server_name: event.server&.name,
          server_id: event.server&.id
        })

        # Get thread_id using improved thread detection
        thread_id = nil
        begin
          # Check if the channel is a thread type (type 11 or 12 in Discord API)
          if event.message.respond_to?(:channel) && event.message.channel.respond_to?(:type)
            channel_type = event.message.channel.type

            # Discord channel types: 11 = public thread, 12 = private thread
            if [ 11, 12 ].include?(channel_type)
              thread_id = event.channel.id
              Rails.logger.info "Thread detected via channel type: ID=#{thread_id}, Name=#{event.channel.name}"
              
              # Store thread information for language detection
              @llm.data_store.store_channel_info(thread_id, {
                name: event.channel.name,
                parent_channel_id: channel_id,
                parent_channel_name: event.message.channel.parent&.name
              })
            end
          end

          # Fallback to traditional thread detection if needed
          if thread_id.nil? && event.message.respond_to?(:thread)
            thread_id = event.message.thread&.id
            Rails.logger.info "Thread ID from event.message.thread&.id: #{thread_id.inspect}" if thread_id
            
            if thread_id
              # Store thread information for language detection
              thread_name = event.message.thread&.name || ""
              @llm.data_store.store_channel_info(thread_id, {
                name: thread_name,
                parent_channel_id: channel_id,
                parent_channel_name: event.channel.name
              })
            end
          end
        rescue => e
          Rails.logger.error "Error getting thread ID: #{e.message}"
        end

        raw_message = event.content.strip
        # Replace user mentions with usernames
        raw_message.scan(/<@!?\d+>/).each do |mention|
          begin
            Rails.logger.info "mention: #{mention}"
            user_id = mention.scan(/\d+/).first.to_i
            Rails.logger.info "user_id: #{user_id}"
            user_lookup = @bot.user(user_id)
            Rails.logger.info "user_lookup: #{user_lookup}"
            raw_message = raw_message.gsub(mention, user_lookup.name)
          rescue => e
            Rails.logger.error "Error replacing mention: #{e.message}"
          end
        end

        user_message = "#{event.user.name}: #{raw_message}"
        Rails.logger.info "User message: #{user_message}"
        response = @llm.generate_response(user_message, channel_id, thread_id)
        Rails.logger.info "Response: #{response}"

        # Only respond if we have a valid response
        event.respond response if response && !response.empty?
      end
    end
  end
end
