✅ DONE
- [x] basic bot runs
- [x] ruby reload
- [x] Fix message parsing issues
  - [x] Investigate JSON parsing problems
  - [x] Evaluate current prompt parsing
  - [x] Research alternative models
  - [x] Review OpenRouter config options
  * [x] pay open router to use other models
* send a hello message on restart
* [x] handle incoming username - looks like it gives us a discord user id
gotta find the api docs
* [x] 4o-mini has 2k character context window
  * first build context from messages, convert to string, rip off last 1999 characters
    * this would require some string building
  or
  * grab last few records

🔄 NOW
* [ ] move into rails

* [ ] add message storage

🎯 NEXT
- [ ] Evaluate running bot on pairing
- [ ] Consider monorepo integration

🔜 SOON
* [ ] mention in thread appears to break
- [ ] Implement longer chat history handling
- [ ] Investigate local bundler directory for Cursor
- [ ] Add debugging/database logging for requests

* recover from an error by rebooting