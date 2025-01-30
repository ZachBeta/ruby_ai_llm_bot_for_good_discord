require 'net/http'
require 'json'
require 'uri'
require_relative 'data_store'

class LlmClient
  attr_accessor :data_store

  BASE_URL = 'https://openrouter.ai/api/v1/chat/completions'

  def initialize
    # @api_key = ENV['OPENROUTER_API_KEY']
    @api_key = ENV['OPEN_ROUTER_API_KEY_DEEP_PURPLE']
    puts "LLM client initialized with API key: #{@api_key[0..5]}...#{@api_key[-5..-1]}"
    @data_store = DataStore.new
  end

  def generate_response(prompt)
    p "generate_response called with prompt: #{prompt}"
    @data_store.store({
      prompt: prompt,
    })
    messages = build_messages(prompt)
    p "messages: #{messages}"
    response = make_request(messages)
    @data_store.store({
      response: response
    })
    response
  end

  private

  def build_messages(prompt)
    system_prompt = [
      {
        role: 'system',
        content: "You are a helpful assistant. You answer short and concise."
      },
    ]
    system_prompt + @data_store.get_messages
  end

  def make_request(messages)
    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = {
      model: "google/gemini-flash-1.5",
      messages: messages
    }.to_json

    p "request body: #{request.body}"
    response = http.request(request)
    p "response body parsed: #{JSON.parse(response.body)}"
    p "response body parsed choices first message content: #{JSON.parse(response.body)['choices'][0]['message']['content']}"
    good_response = JSON.parse(response.body)['choices'][0]['message']['content']

    # trim good_response down to 2000 characters
    good_response = good_response[0..2000]
    good_response
  end

  def parse_response(response)
    return 'Error communicating with LLM' unless response.is_a?(Net::HTTPSuccess)
    
    JSON.parse(response.body).dig('choices', 0, 'message', 'content')
  rescue JSON::ParserError
    'Error parsing LLM response'
  end
end 