require 'net/http'
require 'json'
require 'uri'
require_relative 'data_store'

class LlmClient
  BASE_URL = 'https://openrouter.ai/api/v1/chat/completions'

  def initialize
    # @api_key = ENV['OPENROUTER_API_KEY']
    @api_key = ENV['OPEN_ROUTER_API_KEY_DEEP_PURPLE']
    puts "LLM client initialized with API key: #{@api_key[0..5]}...#{@api_key[-5..-1]}"
    @data_store = DataStore.new
  end

  def generate_response(prompt)
    # p "prompt: #{prompt}"
    response = make_request(build_messages(prompt))
    # response = make_request(prompt)

    # p "response: #{response}"
    # p "response body: #{response.body}"
    # p "response body parsed: #{JSON.parse(response.body)}"
    # p "response code: #{response.code}"

    # foo = parse_response(response)
    # p "foo: #{foo}"
    # "hello world from generate_response"
    # pair the prompt & response
    # send that data to DataStore

    data_store.store({
      prompt: prompt,
      response: response
    })

    p response
    response
  end

  private

  def build_messages(prompt)
    # content = [{ type: 'text', text: prompt }]
    # message_array = [{ role: 'user', content: content }]

    # TODO: add a system level prompt to keep responses short and concise
    foo = [{
      role: 'user',
      content: {
        type: 'text',
        text: prompt
      }
    }]

    # message_array
    foo
  end

  def make_request(messages)
    p "messages: #{messages}"
    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = {
      # model: "google/gemini-flash-1.5-8b",
      # prompt: messages,
      # model: 'meta-llama/llama-3.2-90b-vision-instruct:free',
      # model: "deepseek/deepseek-r1",
      model: "deepseek/deepseek-chat",
      messages: messages
    }.to_json

    p "request body: #{request.body}"
    # p request.body
    # p http.request(request) 
    response = http.request(request)
    # p "response: #{response}"
    # p "response code: #{response.code}"
    # p "response body: #{response.body}"
    p "response body parsed: #{JSON.parse(response.body)}"
    # p "response body parsed choices: #{JSON.parse(response.body)['choices']}"
    # p "response body parsed choices first: #{JSON.parse(response.body)['choices'][0]}"
    # p "response body parsed choices first message: #{JSON.parse(response.body)['choices'][0]['message']}"
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