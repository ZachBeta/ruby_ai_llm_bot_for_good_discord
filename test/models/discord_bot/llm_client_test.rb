require "test_helper"

module DiscordBot
  class LlmClientTest < ActiveSupport::TestCase
    setup do
      @llm_client = LlmClient.new
      @prompt_service = PromptService.new
      # Clear any existing prompts before each test
      Prompt.destroy_all
    end

    test "get_system_prompt_content uses default prompt when available" do
      # Create a default prompt
      @prompt_service.create("default", "Custom default prompt")
      
      # Set bot name for testing
      ENV["BOT_NAME"] = "TestBot"
      
      # Call the private method
      system_prompt = @llm_client.send(:get_system_prompt_content)
      
      # Check that it contains our custom prompt
      assert_includes system_prompt, "Custom default prompt"
      assert_includes system_prompt, "Your name is TestBot"
    end

    test "get_system_prompt_content uses fallback when no default prompt exists" do
      # Ensure no default prompt exists
      assert_nil @prompt_service.find_by_name("default")
      
      # Set bot name for testing
      ENV["BOT_NAME"] = "TestBot"
      
      # Call the private method
      system_prompt = @llm_client.send(:get_system_prompt_content)
      
      # Check that it contains the fallback prompt
      assert_includes system_prompt, "You are a helpful assistant"
      assert_includes system_prompt, "Your name is TestBot"
    end

    test "build_messages includes system prompt and conversation history" do
      # Create a default prompt
      @prompt_service.create("default", "Test system prompt")
      
      # Create some conversation history
      @llm_client.data_store.store({
        channel_id: "test_channel",
        prompt: "User message",
        timestamp: Time.now
      })
      
      @llm_client.data_store.store({
        channel_id: "test_channel",
        response: "Bot response",
        timestamp: Time.now
      })
      
      # Call the private method
      messages = @llm_client.send(:build_messages, "test_channel", nil, "New message")
      
      # Check structure
      assert_equal 3, messages.length
      
      # First message should be system prompt
      assert_equal "system", messages[0][:role]
      assert_includes messages[0][:content], "Test system prompt"
      
      # Second message should be user's previous message
      assert_equal "user", messages[1][:role]
      assert_equal "User message", messages[1][:content]
      
      # Third message should be bot's previous response
      assert_equal "assistant", messages[2][:role]
      assert_equal "Bot response", messages[2][:content]
    end
  end
end 