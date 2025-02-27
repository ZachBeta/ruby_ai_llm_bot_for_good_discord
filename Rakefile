require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc 'Run data store tests'
  Rake::TestTask.new(:data_store) do |t|
    t.libs << 'test'
    t.pattern = 'test/lib/data_store_test.rb'
    t.verbose = true
  end
  
  desc 'Run LLM client tests'
  Rake::TestTask.new(:llm_client) do |t|
    t.libs << 'test'
    t.pattern = 'test/lib/llm_client_test.rb'
    t.verbose = true
  end
  
  desc 'Run Discord bot tests'
  Rake::TestTask.new(:discord_bot) do |t|
    t.libs << 'test'
    t.pattern = 'test/discord_bot_test.rb'
    t.verbose = true
  end
end

task default: :test 