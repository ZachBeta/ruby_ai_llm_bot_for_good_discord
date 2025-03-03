namespace :discord_bot do
  desc "Start the Discord bot"
  task start: :environment do
    bot = DiscordBot::BotService.new
    bot.start
  end
end
