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
      setup_message_handler
    end

    def setup_debug_command
      @bot.message do |event|
        next unless event.content.start_with?("!debug")
        Rails.logger.info "!debug command received"
        channel_id = event.channel.id
        channel_count = @llm.data_store.channel_count
        total_message_count = @llm.data_store.size

        response = <<~STR
          Using model: #{ENV['BOT_STRING']}
          Active channels: #{channel_count}
          Total message count: #{total_message_count}
        STR
        event.respond response
      end
    end

    def setup_clear_command
      @bot.message do |event|
        next unless event.content.start_with?("!clear")
        Rails.logger.info "!clear command received"
        channel_id = event.channel.id
        thread_id = event.message&.thread&.id

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

          **Conversation:**
          Just mention the bot or send a message in an allowed channel to start a conversation.
          You can also include commands anywhere in your message.
        HELP

        event.respond help_text
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
                event.content.start_with?("!help")

        # Get allowed channels from env (comma-separated list of channel IDs)
        allowed_channels = ENV["BOT_ALLOWED_CHANNELS"]&.split(",")&.map(&:strip) || []

        # Skip if the bot isn't mentioned and not in an allowed channel
        bot_mentioned = event.content.include?("<@#{@bot.profile.id}>") ||
                        event.content.include?("<@!#{@bot.profile.id}>")
        is_allowed_channel = allowed_channels.include?(event.channel.id.to_s)

        next unless bot_mentioned || is_allowed_channel

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
        Rails.logger.info "=========================="

        channel_id = event.channel.id

        # if there is a thread, use it
        # otherwise, use the channel id
        thread_id = nil
        begin
          thread_id = event.message&.thread&.id
        rescue
          Rails.logger.info "No thread ID found"
        end

        raw_message = event.content.strip
        # Replace user mentions with usernames
        raw_message.scan(/<@!?\d+>/).each do |mention|
          Rails.logger.info "mention: #{mention}"
          user_id = mention.scan(/\d+/).first.to_i
          Rails.logger.info "user_id: #{user_id}"
          user_lookup = @bot.user(user_id)
          Rails.logger.info "user_lookup: #{user_lookup}"
          raw_message = raw_message.gsub(mention, user_lookup.name)
        end

        user_message = "#{event.user.name}: #{raw_message}"
        Rails.logger.info "User message: #{user_message}"
        response = @llm.generate_response(user_message, channel_id, thread_id)
        Rails.logger.info "Response: #{response}"
        event.respond response
      end
    end
  end
end
