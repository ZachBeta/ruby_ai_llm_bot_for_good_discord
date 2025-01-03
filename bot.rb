require 'discordrb'
require 'dotenv/load'
require 'listen'
require_relative 'lib/llm_client'

class DiscordBot
  def initialize
    @bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
    @llm = LlmClient.new
    setup_commands
    setup_auto_reload
  end

  def start
    @bot.run
  end

  private

  def setup_auto_reload
    listener = Listen.to('.') do |modified, added, removed|
      files = modified + added + removed
      if files.any? { |f| f.end_with?('.rb') }
        puts "Reloading due to changes in: #{files.join(', ')}"
        exec('ruby', __FILE__)
      end
    end
    listener.start
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