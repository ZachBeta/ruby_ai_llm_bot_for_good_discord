require 'test_helper'

class DataStoreTest < Minitest::Test
  def test_store_get_store_get
    # given
    data_store = DataStore.new
    data_store.store({
      prompt: "What is the capital of France?",
      response: "The capital of France is Paris."
    })
    # when
    data_store.get_messages
    # then
    assert_equal data_store.get_messages, [
      {
        role: 'user',
        content: "What is the capital of France?"
      },
      {
        role: 'assistant',
        content: "The capital of France is Paris."
      }
    ]
  end

  def test_store_get_store_get_double_up_front
    data_store = DataStore.new
    data_store.store({
      prompt: "What is the capital of France?",
      response: "The capital of France is Paris."
    })
    data_store.store({
      prompt: "Tell me about coffee there",
      response: "There is a lot of coffee in Paris France. As it is a capital city."
    })

    expected_messages = [
      {
        role: 'user',
        content:  "What is the capital of France?"
      },
      {
        role: 'assistant',
        content: "The capital of France is Paris."
      },
      {
        role: 'user',
        content: "Tell me about coffee there"
      },
      {
        role: 'assistant',
        content: "There is a lot of coffee in Paris France. As it is a capital city."
      }
    ]
    assert_equal data_store.get_messages, expected_messages
  end

  def test_store_one_prompt_one_response
    data_store = DataStore.new
    data_store.store({
      prompt: "What is the capital of France?",
    })
    data_store.store({
      response: "The capital of France is Paris."
    })
    assert_equal data_store.get_messages, [
      {
        role: 'user',
        content: "What is the capital of France?"
      },
      {
        role: 'assistant',
        content: "The capital of France is Paris."
      }
    ]
  end
end
