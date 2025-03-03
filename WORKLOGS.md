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

🔄 NOW

🎯 NEXT

- [ ] attempt at using `I'm considering using Rails ActiveRecord to store the messages in sqlite so we don't lose memory on restart` as prompt got a bit off the beaten path
  - needs some direction to keep the API of datastore the same, and make changes from there down
  - consider spinning up another bot to act as avant garde experiments, and keep BodgeIt as a stable copy
  - run said stable copy on a server that's long living
- [ ] Prompt engineering
  - [ ] Store useful prompts to reuse with - rails g migration prompt content:string
- [ ] Consider monorepo integration 
- [ ] Consider pulling in only AREL for persistence
- [ ] Drop into Rails 8 for more general tooling access in codebase
  - [ ] Store messages - rails g migration message role:string content:string


🔜 SOON

- [ ] Fix mention in thread breaking issue
- [ ] Implement longer chat history handling
- [ ] Add debugging/database logging for requests
- [ ] Implement error recovery by rebooting
- [ ] containerize to simplify setup