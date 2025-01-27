require 'minitest/autorun'
require 'minitest/pride'
require 'dotenv/load'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require_relative '../lib/llm_client'
require_relative '../lib/data_store'
# require_relative '../bot' 
