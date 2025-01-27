# Discord Bot with OpenRouter LLM Integration

## set up ruby
* https://rvm.io/
* check out rvm and rbenv
   * rvm is probably easier

## Test
```
bundle exec rake test
```

## Run
```
bundle exec ruby bot.rb
```

we want to store all messages in memory, can we make a dictionary or map on every messge sent and received, we call this function and store in an instrance variable

## Setup
1. Create a Discord Application
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application" and give it a name
   - Go to the "Bot" section and click "Add Bot"
   - Copy the bot token

2. Get OpenRouter API Key
   - Go to [OpenRouter](https://openrouter.ai/)
   - Create an account and get your API key

3. Install Dependencies
   ```bash
   bundle init
   bundle add discordrb dotenv
   ```

4. Configure Environment
   Create a `.env` file with:
   ```
   DISCORD_TOKEN=your_discord_token
   OPENROUTER_API_KEY=your_openrouter_key
   ```

5. Invite Bot to Server
   - In Developer Portal, go to OAuth2 > URL Generator
   - Select "bot" under scopes
   - Select needed permissions (Send Messages)
   - Use generated URL to invite bot

## Usage
1. Run the bot:
   ```bash
   ruby bot.rb
   ```

2. Bot Commands:
   - `!ping` - Bot replies "Pong!"
   - `@BotName <prompt>` - Bot generates response using OpenRouter LLM
   - For images, include an image URL in your message

## Example