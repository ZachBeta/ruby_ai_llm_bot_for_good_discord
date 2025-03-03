# Discord Bot for Good Discord

This is a Rails application that runs a Discord bot powered by LLMs.

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
   DISCORD_CHANNEL_ID="your-discord-channel-id"
   OPENROUTER_API_KEY="your-openrouter-api-key"
   BOT_STRING="anthropic/claude-3.5-sonnet" # or any other model
   ```

## Running the bot

To start the Discord bot:

```
rails discord_bot:start
```

## Features

* Responds to messages in allowed channels or when mentioned
* Maintains conversation history per channel/thread in the database
* Supports clearing conversation history with `!clear` command
* Provides debug information with `!debug` command

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
