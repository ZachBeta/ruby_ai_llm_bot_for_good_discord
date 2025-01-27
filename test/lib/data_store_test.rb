require 'test_helper'

class DataStoreTest < Minitest::Test
  def test_array_stuff
    skip
    arr = [1, 2, 3]
    # assert_equal "fail", arr.push(4)
    # assert_equal "fail2", arr
    assert_equal [1, 2, 3, 4], arr
    arr << 5
    assert_equal [1, 2, 3, 4, 5], arr
  end

  def test_data_store_exists
    skip
    assert defined?(DataStore), "DataStore class should be defined"
  end

  def test_store_array_has_data
    skip
    # given
    messages = DataStore.new
    messages.store({
      prompt: "What is the capital of France?",
      response: "The capital of France is Paris."
    })

    # when
    actual = messages.fetch_raw_store
    expected = [
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
    
    # then
    assert_equal expected, actual

    # assert_equal messages.store, [{
    #   prompt: "What is the capital of France?",
    #   response: "The capital of France is Paris."
    # }]
  end

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
      },
      {
        role: 'user',
        content: {
          type: 'text',
          text: "Tell me about coffee there"
        }
      },
      {
        role: 'assistant',
        content: {
          type: 'text',
          text: "There is a lot of coffee in Paris France. As it is a capital city."
        }
      }
    ]
    assert_equal data_store.get_messages, expected_messages
  end
end
