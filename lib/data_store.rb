class DataStore
  def initialize
    # @messages = {}
  end

  def store(name)
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