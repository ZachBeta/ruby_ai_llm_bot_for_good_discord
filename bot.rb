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
    setup_auto_reload

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
      prompt = event.content.gsub(/<@!?\d+>/, '').strip
      response = @llm.generate_response(prompt)
      event.respond response
    end
  end
end

bot = DiscordBot.new
bot.start 