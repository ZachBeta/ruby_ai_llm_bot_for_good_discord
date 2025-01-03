require 'net/http'
require 'json'
require 'uri'

class LlmClient
  BASE_URL = 'https://openrouter.ai/api/v1/chat/completions'

  def initialize
    # @api_key = ENV['OPENROUTER_API_KEY']
    @api_key = "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"
  end

  def generate_response(prompt, image_url = nil)
    response = make_request(build_messages(prompt, image_url))
    p response
    parse_response(response)
  end

  private

  def build_messages(prompt, image_url)
    content = [{ type: 'text', text: prompt }]
    content << { type: 'image_url', image_url: { url: image_url } } if image_url
    [{ role: 'user', content: content }]
  end

  def make_request(messages)
    uri = URI(BASE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{@api_key}"
    request.body = {
      model: 'meta-llama/llama-3.2-90b-vision-instruct:free',
      messages: messages
    }.to_json

    p request.body
    http.request(request)
  end

  def parse_response(response)
    return 'Error communicating with LLM' unless response.is_a?(Net::HTTPSuccess)
    
    JSON.parse(response.body).dig('choices', 0, 'message', 'content')
  rescue JSON::ParserError
    'Error parsing LLM response'
  end
end 