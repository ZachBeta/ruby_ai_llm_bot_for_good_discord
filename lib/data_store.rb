class DataStore
  def initialize
    # @messages = {}
    @messages = []
  end

  def store(prompt_and_response)
    # arr.each
    # arr.push
    # arr <<
    @messages << prompt_and_response
  end

  def fetch_raw_store
    @messages
  end

  def get_messages 
    [
      {
      role: 'user',
      content: {
          type: 'text',
          text: "What is the capital of France?"
        },
      },
      {
        role: 'assistant',
        content: {
          type: 'text',
          text: "The capital of France is Paris."
        }
      }
    ]
  end
end