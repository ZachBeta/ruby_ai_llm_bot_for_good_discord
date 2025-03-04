# Discord Bot for Good Discord

This is a Rails application that runs a Discord bot powered by LLMs via OpenRouter.

## Prerequisites

* Ruby 3.2.0 or higher
* Rails 8.0.1
* Discord bot token
* OpenRouter API key

## Setup

1. Clone the repository
2. Install dependencies:
   ```
   bundle install
   ```
3. Set up the database:
   ```
   rails db:migrate
   ```
4. Set up environment variables in `.env`:
   ```
   DISCORD_TOKEN="your-discord-token"
   DISCORD_CHANNEL_ID="your-discord-channel-id" # Channel for bot status notifications
   OPENROUTER_API_KEY="your-openrouter-api-key"
   BOT_STRING="anthropic/claude-3.5-sonnet" # or any other model
   BOT_ALLOWED_CHANNELS="channel-id-1,channel-id-2" # Optional: Channels where bot responds without being mentioned
   ```

   **Environment Variables Explained:**
   - `DISCORD_TOKEN`: Your Discord bot's authentication token
   - `DISCORD_CHANNEL_ID`: Channel where the bot sends status updates (e.g., restart notifications)
   - `OPENROUTER_API_KEY`: Your API key for OpenRouter
   - `BOT_STRING`: The LLM model to use via OpenRouter
   - `BOT_ALLOWED_CHANNELS`: Optional comma-separated list of channel IDs where the bot will respond to all messages (not just when mentioned)

5. Discord Bot Setup:
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Click "New Application" and give it a name
   - Go to the "Bot" section and click "Add Bot"
   - Scroll to privileged gateway intents
     - Enable all 3 toggles for presence, server members, message content
   - Reset token and copy it
   - In Developer Portal, go to OAuth2 > URL Generator
   - Select "bot" under scopes
   - Select needed permissions:
     - Send Messages
     - Send Messages in Threads
     - Read Message History
   - Discord admin can use generated URL to invite bot
   - Confirm by going to server settings > apps/integrations > bots & apps

6. OpenRouter Setup:
   - Go to [OpenRouter](https://openrouter.ai/)
   - Create an account and get your API key from https://openrouter.ai/settings/keys

## Running the bot

To start the Discord bot:

```
rails discord_bot:start
```

## Testing

Run the test suite with:

```
bundle exec rake test
```

## Features

* Responds to messages in allowed channels or when mentioned
  - In channels listed in `BOT_ALLOWED_CHANNELS`: Responds to all messages
  - In other channels: Only responds when directly mentioned
* Sends status notifications to the channel specified in `DISCORD_CHANNEL_ID`
* Maintains conversation history per channel/thread in the database
* Supports clearing conversation history with `!clear` command
* Provides debug information with `!debug` command
* Bot Commands:
  - `!debug @bot` - gives basic debug details
  - `!ping` - Bot replies "Pong!"
  - `@BotName <prompt>` - Bot generates response using the configured LLM
  - For images, include an image URL in your message

## Prompt Management

The bot now supports storing and managing prompts. Here are the available commands:

### List all prompts
```
!prompts
```
Lists all available prompts by name.

### Create or update a prompt
```
!prompt set [name] [content]
```
Creates a new prompt or updates an existing one with the given name and content.

### Get a prompt
```
!prompt get [name]
```
Displays the content of the prompt with the given name.

### Delete a prompt
```
!prompt delete [name]
```
Deletes the prompt with the given name.

### Set default prompt
```
!prompt default [name]
```
Sets the prompt with the given name as the default system prompt for all conversations.

## Development

The bot code is organized in the `app/services/discord_bot` directory:

* `bot_service.rb` - Main Discord bot service
* `llm_client.rb` - Client for interacting with LLMs via OpenRouter
* `data_store.rb` - Database storage for conversation history

## Database

The application uses a SQLite database to store conversation history. The schema includes:

* `conversations` - Stores messages and responses with channel and thread IDs

## Development Tools

### Conversation Query Service

For development and debugging purposes, the application includes a `ConversationQueryService` that allows you to query and inspect conversation data.

#### Using the Command-Line Script

```
ruby script/conversation_query.rb COMMAND [ARGS]
```

Available commands:
* `recent [LIMIT]` - Show recent conversations (default: 10)
* `channel CHANNEL_ID [LIMIT]` - Show conversations for a specific channel
* `thread THREAD_ID [LIMIT]` - Show conversations for a specific thread
* `search TERM [LIMIT]` - Search conversations containing a term
* `stats` - Show conversation statistics

Examples:
```
ruby script/conversation_query.rb recent 5
ruby script/conversation_query.rb channel 123456789 3
ruby script/conversation_query.rb thread 987654321
ruby script/conversation_query.rb search "hello world"
ruby script/conversation_query.rb stats
```

#### Using Rake Tasks

```
rake conversation:recent[LIMIT]
rake conversation:channel[CHANNEL_ID,LIMIT]
rake conversation:thread[THREAD_ID,LIMIT]
rake conversation:search[TERM,LIMIT]
rake conversation:stats
```

Examples:
```
rake conversation:recent[5]
rake conversation:channel[123456789,3]
rake conversation:thread[987654321]
rake conversation:search["hello world"]
rake conversation:stats
```
