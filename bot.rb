require 'discordrb'
require 'dotenv/load'
require 'listen'
require_relative 'lib/llm_client'

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
    # setup_auto_reload

    puts "Discord bot setup complete."
  end

  def start
    @bot.run
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
    @bot.message(start_with: '!ping') do |event|
      event.respond 'Pong!'
    end

    @bot.mention do |event|
      p "mention event: #{event}"
      p "event.content: #{event.content}"
      p "event.user: #{event.user}"
      p "event.user.name: #{event.user.name}"
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