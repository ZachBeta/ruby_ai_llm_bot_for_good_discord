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

🔄 NOW

- [ ] Complete prompt engineering features
  - [ ] Test prompt commands in Discord
  - [ ] Create experimental bot separate from stable BodgeIt version
  - [ ] Deploy stable version on long-living server

🎯 NEXT

- [ ] Consider monorepo integration
- [ ] Consider pulling in only AREL for persistence
- [ ] Migrate to Rails 8 for better tooling
  - [ ] Implement additional message storage features

🔜 SOON

- [ ] Allow default prompt storage and creation of new prompts from existing ones
- [ ] Fix mention in thread breaking issue
- [ ] Implement longer chat history handling
- [ ] Add debugging/database logging for requests
- [ ] Implement error recovery by rebooting
- [ ] Containerize to simplify setup