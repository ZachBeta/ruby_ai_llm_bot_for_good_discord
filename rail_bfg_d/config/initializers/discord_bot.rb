Rails.application.config.after_initialize do
  # Make sure the Discord bot services are loaded
  Rails.autoloaders.main.eager_load_dir(Rails.root.join('app/services/discord_bot'))
end 