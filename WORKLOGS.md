✅ DONE

- [x] Basic bot runs
- [x] Ruby reload
- [x] Fix message parsing issues
  - [x] Investigate JSON parsing problems
  - [x] Evaluate current prompt parsing
  - [x] Research alternative models
  - [x] Review OpenRouter config options
  - [x] Pay open router to use other models
- [x] Handle incoming username (Discord user ID)
- [x] Investigate local bundler directory for Cursor
- [x] Evaluate running bot on pairing or other durable server
- [x] Implement data persistence
  - [x] Use Rails ActiveRecord with SQLite to store messages
  - [x] Maintain current datastore API while implementing changes
  - [x] Store useful prompts for reuse
- [x] Implement prompt engineering features
  - [x] Create prompt model and service
  - [x] Implement CRUD operations for prompts
  - [x] Test prompt commands in Discord
  - [x] Implement prompt selection in bot commands
  - [x] Add default prompt functionality
- [x] Consider pulling in only AREL for persistence
- [x] Migrate to Rails 8 for better tooling
  - [x] Implement additional message storage features
- [x] Add debugging/database logging for requests

🔄 NOW

- [ ] Implement channel-specific prompts
  - [ ] Extend prompt model to include channel ID
  - [ ] Update prompt service to handle channel-specific prompts
  - [ ] Add commands for managing channel prompts
- [ ] Fix mention in discord thread breaking issue
- [ ] Implement deployment strategy
  - [ ] Create experimental bot separate from stable BodgeIt version
  - [ ] Deploy stable version on long-living server
  - [ ] Containerize to simplify setup

🎯 NEXT

- [ ] Enhance conversation management
  - [ ] Implement longer chat history handling
  - [ ] Add tests to confirm chat history functionality
  - [ ] Improve error handling and recovery
- [ ] Improve prompt system
  - [ ] Enable creation of new prompts from existing ones
  - [ ] Add user preferences for default prompts

🔜 FUTURE

- [ ] Consider monorepo integration
- [ ] Implement advanced features
  - [ ] Add support for multiple LLM providers
  - [ ] Implement conversation summarization
  - [ ] Add analytics for bot usage
- [ ] Improve documentation
  - [ ] Create comprehensive setup guide
  - [ ] Document API and service architecture
  - [ ] Add examples for common use cases