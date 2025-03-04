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
* Bot Commands:
  - `!debug @bot` - gives basic debug details
  - `!ping` - Bot replies "Pong!"
  - `@BotName <prompt>` - Bot generates response using the configured LLM
  - For images, include an image URL in your message

## Prompt Management

The bot now supports storing and managing prompts, including channel-specific prompts. Here are the available commands:

### List prompts
```
!prompts
```
Lists all global prompts by name.

```
!prompts --channel
```
Lists all prompts available for the current channel (both channel-specific and global).

### Create or update a prompt
```
!prompt set [name] [content]
```
Creates a new global prompt or updates an existing one with the given name and content.

```
!prompt set [name] [content] --channel
```
Creates a new channel-specific prompt or updates an existing one for the current channel.

### Get a prompt
```
!prompt get [name]
```
Displays the content of the global prompt with the given name.

```
!prompt get [name] --channel
```
Displays the content of the channel-specific prompt with the given name, or falls back to the global prompt if no channel-specific prompt exists.

### Delete a prompt
```
!prompt delete [name]
```
Deletes the global prompt with the given name.

```
!prompt delete [name] --channel
```
Deletes the channel-specific prompt with the given name for the current channel.

### Set default prompt
```
!prompt default [name]
```
Sets the prompt with the given name as the default system prompt for all conversations globally.

```
!prompt default [name] --channel
```
Sets the prompt with the given name as the default system prompt for conversations in the current channel.

## Development

The bot code is organized in the `app/services/discord_bot` directory:

* `bot_service.rb` - Main Discord bot service
* `llm_client.rb` - Client for interacting with LLMs via OpenRouter
* `data_store.rb` - Database storage for conversation history
* `prompt_service.rb` - Service for managing prompts

## Database

The application uses a SQLite database to store conversation history and prompts. The schema includes:

* `conversations` - Stores messages and responses with channel and thread IDs
* `prompts` - Stores prompts with name, content, and optional channel_id

## Development Tools

### Conversation Query Service

For development and debugging purposes, the application includes a `ConversationQueryService` that allows you to query and inspect conversation data.
