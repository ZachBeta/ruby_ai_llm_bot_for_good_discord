require "net/http"
require "json"
require "uri"

module DiscordBot
  class LlmClient
    attr_accessor :data_store

    BASE_URL = "https://openrouter.ai/api/v1/chat/completions"

    def initialize
      @api_key = ENV["OPENROUTER_API_KEY"]
      Rails.logger.info "LLM client initialized with API key: #{@api_key[0..5]}...#{@api_key[-5..-1]}"
      @data_store = DataStore.new
      @prompt_service = PromptService.new
    end

    def generate_response(prompt, channel_id = nil, thread_id = nil)
      Rails.logger.info "generate_response called with prompt: #{prompt}, channel_id: #{channel_id}, thread_id: #{thread_id}"
      @data_store.store({
        prompt: prompt,
        channel_id: channel_id,
        thread_id: thread_id,
        timestamp: Time.now
      })

      messages = build_messages(channel_id, thread_id, prompt)
      Rails.logger.info "messages: #{messages}"

      response = make_request(messages)
      bot_name = ENV["BOT_NAME"] || "Bot"
      formatted_response = "#{bot_name}: #{response}"

      @data_store.store({
        response: formatted_response,
        channel_id: channel_id,
        thread_id: thread_id,
        timestamp: Time.now
      })

      response
    end

    private

    def build_messages(channel_id, thread_id, prompt)
      # Get default system prompt or use fallback
      system_prompt_content = get_system_prompt_content

      system_prompt = [
        {
          role: "system",
          content: system_prompt_content
        }
      ]

      # Get conversation history for this channel/thread
      history = @data_store.get_messages(channel_id, thread_id)

      system_prompt + history
    end

    def get_system_prompt_content
      default_prompt = @prompt_service.find_by_name("default")
      bot_name = ENV["BOT_NAME"] || "Bot"
      base_prompt = default_prompt&.content || "You are a helpful assistant. You answer short and concise."
      
      # Add bot identity information to the system prompt
      identity_info = "Your name is #{bot_name}. When users refer to '#{bot_name}' in the conversation, they are referring to you."
      
      "#{base_prompt}\n\n#{identity_info}"
    end

    def make_request(messages)
      uri = URI(BASE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@api_key}"
      request.body = {
        model: ENV["BOT_STRING"] || "google/gemini-flash-1.5",
        messages: messages
      }.to_json

      Rails.logger.info "request body: #{request.body}"
      response = http.request(request)
      Rails.logger.info "response body parsed: #{JSON.parse(response.body)}"
      Rails.logger.info "response body parsed choices first message content: #{JSON.parse(response.body)['choices'][0]['message']['content']}"
      good_response = JSON.parse(response.body)["choices"][0]["message"]["content"]

      # trim good_response down to 2000 characters
      good_response = good_response[0..2000]
      good_response
    end

    def parse_response(response)
      return "Error communicating with LLM" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body).dig("choices", 0, "message", "content")
    rescue JSON::ParserError
      "Error parsing LLM response"
    end
  end
end
