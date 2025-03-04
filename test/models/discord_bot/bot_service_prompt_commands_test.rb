require "test_helper"

module DiscordBot
  class BotServicePromptCommandsTest < ActiveSupport::TestCase
    setup do
      # Mock the Discord bot
      @mock_bot = Minitest::Mock.new
      
      # Mock the profile for the bot
      mock_profile = Minitest::Mock.new
      mock_profile.expect :id, "123456789"
      mock_profile.expect :name, "TestBot"
      
      # Set up the mock bot to return the mock profile
      @mock_bot.expect :profile, mock_profile
      
      # Create a BotService instance with the mock bot
      @bot_service = BotService.new
      @bot_service.instance_variable_set(:@bot, @mock_bot)
      
      # Get access to the prompt service
      @prompt_service = @bot_service.instance_variable_get(:@prompt_service)
      
      # Clear any existing prompts before each test
      Prompt.destroy_all
    end
    
    test "setup_prompt_commands registers message handlers" do
      # This test verifies that the setup_prompt_commands method registers
      # message handlers for each prompt command
      
      # We'll mock the message method to verify it's called for each command
      message_calls = 0
      @mock_bot.expect :message, nil do
        message_calls += 1
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
      
      # Verify message was called for each command (list, set, get, delete, default)
      assert_equal 5, message_calls
    end
    
    test "prompt set command creates a new prompt" do
      # Create a mock event for the !prompt set command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompt set test_prompt This is a test prompt"
      mock_event.expect :respond, nil, ["Prompt 'test_prompt' created."]
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
      
      # Verify the prompt was created
      prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal "This is a test prompt", prompt.content
    end
    
    test "prompt set command updates an existing prompt" do
      # Create an existing prompt
      @prompt_service.create("test_prompt", "Original content")
      
      # Create a mock event for the !prompt set command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompt set test_prompt Updated content"
      mock_event.expect :respond, nil, ["Prompt 'test_prompt' updated."]
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
      
      # Verify the prompt was updated
      prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal "Updated content", prompt.content
    end
    
    test "prompt get command displays a prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "This is a test prompt")
      
      # Create a mock event for the !prompt get command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompt get test_prompt"
      mock_event.expect :respond, nil, ["Prompt 'test_prompt':\n```\nThis is a test prompt\n```"]
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
    end
    
    test "prompt delete command removes a prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "This is a test prompt")
      
      # Create a mock event for the !prompt delete command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompt delete test_prompt"
      mock_event.expect :respond, nil, ["Prompt 'test_prompt' deleted."]
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
      
      # Verify the prompt was deleted
      assert_nil @prompt_service.find_by_name("test_prompt")
    end
    
    test "prompt default command sets the default prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "This is a test prompt")
      
      # Create a mock event for the !prompt default command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompt default test_prompt"
      mock_event.expect :respond, nil, ["Default prompt set to 'test_prompt'."]
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
      
      # Verify the default prompt was set
      default_prompt = @prompt_service.find_by_name("default")
      assert_equal "This is a test prompt", default_prompt.content
    end
    
    test "prompts command lists all prompts" do
      # Create some prompts
      @prompt_service.create("prompt1", "Content 1")
      @prompt_service.create("prompt2", "Content 2")
      
      # Create a mock event for the !prompts command
      mock_event = Minitest::Mock.new
      mock_event.expect :content, "!prompts"
      mock_event.expect :respond, nil do |response|
        # Check that the response contains both prompt names
        response.include?("prompt1") && response.include?("prompt2")
      end
      
      # Set up the message handler
      @mock_bot.expect :message, nil do |&block|
        # Call the block with our mock event
        block.call(mock_event)
      end
      
      # Call the method
      @bot_service.send(:setup_prompt_commands)
    end
  end
end 