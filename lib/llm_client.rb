require 'net/http'
require 'json'
require 'uri'

class LlmClient
  BASE_URL = 'https://openrouter.ai/api/v1/chat/completions'

  def initialize
    @api_key = ENV['OPENROUTER_API_KEY']
    puts "LLM client initialized with API key: #{@api_key[0..5]}...#{@api_key[-5..-1]}"
  end

  def generate_response(prompt, image_url = nil)
    p "prompt: #{prompt}"
    # response = make_request(build_messages(prompt, image_url))
    response = make_request(prompt)

    p "response: #{response}"
    p "response body: #{response.body}"
    p "response body parsed: #{JSON.parse(response.body)}"

    parse_response(response)
  end

  private

  def build_messages(prompt, image_url)
    content = [{ type: 'text', text: prompt }]
    content << { type: 'image_url', image_url: { url: image_url } } if image_url
    [{ role: 'user', content: content }]
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
      model: "google/gemini-flash-1.5-8b",
      prompt: messages,
      # model: 'meta-llama/llama-3.2-90b-vision-instruct:free',
      # messages: messages
    }.to_json

    # p request.body
    http.request(request)
  end

  def parse_response(response)
    return 'Error communicating with LLM' unless response.is_a?(Net::HTTPSuccess)
    
    JSON.parse(response.body).dig('choices', 0, 'message', 'content')
  rescue JSON::ParserError
    'Error parsing LLM response'
  end
end 