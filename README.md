# Discord Bot with OpenRouter LLM Integration

```
bundle exec rake test
```

## Run

```
bundle exec ruby bot.rb
```

## Setup

1. Create a Discord Application

   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application" and give it a name
   - Go to the "Bot" section and click "Add Bot"

   * scroll to privileged gateway intents
     - flip all 3 toggles for presence, server members, message content
   * reset token

   - Copy the bot token

2. Get OpenRouter API Key

   - Go to [OpenRouter](https://openrouter.ai/)
   - Create an account and get your API key
   - https://openrouter.ai/settings/keys

3. Configure Environment
   Create a `.env` file with:

   ```
   DISCORD_TOKEN=your_discord_token
   OPENROUTER_API_KEY=your_openrouter_key
   ```

4. Install Dependencies

   Install ruby

```bash
# Install rbenv using Homebrew
brew install rbenv

# Add rbenv to your shell
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
rbenv install 3.2.2
rbenv global 3.2.2

# Verify installation
ruby -v
gem install bundler
```

Install bundler and bundle install all the gems

```bash
bundle
```

5. Invite Bot to Server
   - In Developer Portal, go to OAuth2 > URL Generator
   - Select "bot" under scopes
   - Select needed permissions (Send Messages)
     - Send Messages
     - Send Messages in Threads
     - Read Message History
   - Discord admin can use generated URL to invite bot
   - Confirm by going to server settings > apps/integrations > bots & apps

## Usage

1. Run the bot:

   ```bash
   ruby bot.rb
   bundle exec ruby bot.rb
   ```

2. Bot Commands:

   - `!debug @bot` - gives basic debug details
   - `!ping` - Bot replies "Pong!" - TODO: does it?
   - `@BotName <prompt>` - Bot generates response using whichever OpenRouter LLM is configured
   - For images, include an image URL in your message

3. switching LLMs
   - find options in https://openrouter.ai/models?order=top-weekly
   - swap the string out in the env var

# TODO:

- confirm .ruby-version
- install latest ruby rather than 3.2.2
- experiment w requests to different LLMs
  - instructions on changing bot string
