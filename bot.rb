require 'discordrb'
require 'dotenv/load'
require 'listen'
require_relative 'lib/llm_client'

# BOT_STRING="deepseek/deepseek-r1-distill-llama-70b"
BOT_STRING="deepseek/deepseek-r1:free"
# BOT_STRING="google/gemini-flash-1.5"
# BOT_STRING="openai/gpt-4o-mini"

class DiscordBot
  def initialize
    puts "Initializing Discord bot..."
    @token = ENV['DISCORD_TOKEN']
    puts "DISCORD_TOKEN: #{@token[0..5]}...#{@token[-5..-1]}"
    @bot = Discordrb::Bot.new(token: @token)
    puts "Discord bot initialized."
    @llm = LlmClient.new
    puts "LLM client initialized."
    setup_commands
    puts "Commands setup."
    send_to_channel(ENV['DISCORD_CHANNEL_ID'], "Restarted\n#{Time.now.iso8601(9)}\n#{BOT_STRING}")
    # setup_auto_reload

    puts "Discord bot setup complete."
  end

  def start
    @bot.run
  end

  def send_to_channel(channel_id, message)
    p "Sending message to channel #{channel_id}: #{message}"
    @bot.send_message(channel_id, message)
  end

  private

  def setup_auto_reload
    puts "Setting up auto-reload..."
    listener = Listen.to('.') do |modified, added, removed|
      files = modified + added + removed
      if files.any? { |f| f.end_with?('.rb') }
        puts "Reloading due to changes in: #{files.join(', ')}"
        exec('ruby', __FILE__)
      end
    end
    listener.start
    puts "Auto-reload started."
  end

  def setup_commands

    @bot.mention do |event|
      p "=== Mention Event Details ==="
      p "Channel ID: #{event.channel.id}"
      p "Channel Name: #{event.channel.name}"
      p "Server ID: #{event.server&.id}"
      p "Server Name: #{event.server&.name}"
      p "Message ID: #{event.message.id}"
      p "Content: #{event.content}"
      p "Author ID: #{event.user.id}"
      p "Author Name: #{event.user.name}"
      p "Timestamp: #{event.timestamp}"
      p "=========================="
      
      raw_message = event.content.strip
      # TODO: search for <@user_id> and replace with user_name
      raw_message.scan(/<@!?\d+>/).each do |mention|
        p "mention: #{mention}"
        user_id = mention.scan(/\d+/).first.to_i
        p "user_id: #{user_id}"
        user_lookup = @bot.user(user_id)
        p "user_lookup: #{user_lookup}"
        raw_message = raw_message.gsub(mention, user_lookup.name)
      end
      
      user_message = "#{event.user.name}: #{raw_message}"
      response = @llm.generate_response(user_message)
      event.respond response
    end
  end
end

bot = DiscordBot.new
bot.start 