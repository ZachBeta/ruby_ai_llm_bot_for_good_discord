require 'test_helper'

class DataStoreTest < Minitest::Test
  def test_data_store_exists
    assert defined?(DataStore), "DataStore class should be defined"
  end
end