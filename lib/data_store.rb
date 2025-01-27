class DataStore
  def initialize
    @messages = []
  end

  def store(prompt_and_response)
    @messages << prompt_and_response
  end

  def fetch_raw_store
    @messages
  end

  def get_messages 
    @messages.inject([]) { |acc, message|
      if message[:prompt] 
        acc << {
          role: 'user',
          content: {
            type: 'text',
            text: message[:prompt]
          },
        }
      end
      if message[:response]
        acc << {
          role: 'assistant',
          content: {
            type: 'text',
            text: message[:response]
          }
        }
      end
      acc
    }
  end
end