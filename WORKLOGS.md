✅ DONE
- [x] basic bot runs
- [x] ruby reload
- [x] Fix message parsing issues
  - [x] Investigate JSON parsing problems
  - [x] Evaluate current prompt parsing
  - [x] Research alternative models
  - [x] Review OpenRouter config options
  * [x] pay open router to use other models

🔄 NOW
* [ ] handle incoming username - looks like it gives us a discord user id
gotta find the api docs

🎯 NEXT
- [ ] Evaluate running bot on pairing
- [ ] Consider monorepo integration

🔜 SOON
- [ ] Implement longer chat history handling
- [ ] Investigate local bundler directory for Cursor
- [ ] Add debugging/database logging for requests
* [ ] 4o-mini has 2k character context window
  * first build context from messages, convert to string, rip off last 1999 characters
    * this would require some string building
  or
  * grab last few records

* recover from an error by rebooting
* send a hello message on restart