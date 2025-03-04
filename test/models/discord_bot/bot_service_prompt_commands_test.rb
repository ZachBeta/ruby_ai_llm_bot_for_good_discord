require "test_helper"

module DiscordBot
  class BotServicePromptCommandsTest < ActiveSupport::TestCase
    setup do
      # Create a PromptService instance for testing
      @prompt_service = PromptService.new

      # Clear any existing prompts before each test
      Prompt.destroy_all
    end

    test "create and find prompt" do
      # Create a new prompt
      prompt = @prompt_service.create("test_prompt", "This is a test prompt")

      # Verify it was created correctly
      assert_equal "test_prompt", prompt.name
      assert_equal "This is a test prompt", prompt.content

      # Verify we can find it
      found_prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal prompt.id, found_prompt.id
    end

    test "update prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "Original content")

      # Update it
      updated_prompt = @prompt_service.update("test_prompt", "Updated content")

      # Verify it was updated
      assert_equal "Updated content", updated_prompt.content

      # Verify the change persisted
      found_prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal "Updated content", found_prompt.content
    end

    test "delete prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "This is a test prompt")

      # Verify it exists
      assert_not_nil @prompt_service.find_by_name("test_prompt")

      # Delete it
      result = @prompt_service.delete("test_prompt")

      # Verify it was deleted
      assert_equal true, result
      assert_nil @prompt_service.find_by_name("test_prompt")
    end

    test "set default prompt" do
      # Create a prompt
      @prompt_service.create("test_prompt", "This is a test prompt")

      # Set it as default (simulating the default command)
      prompt = @prompt_service.find_by_name("test_prompt")
      default_prompt = @prompt_service.find_by_name("default")

      if default_prompt
        @prompt_service.update("default", prompt.content)
      else
        @prompt_service.create("default", prompt.content)
      end

      # Verify the default prompt was set
      default_prompt = @prompt_service.find_by_name("default")
      assert_equal "This is a test prompt", default_prompt.content
    end

    test "list all prompts" do
      # Create some prompts
      @prompt_service.create("prompt1", "Content 1")
      @prompt_service.create("prompt2", "Content 2")

      # Get all prompts
      prompts = @prompt_service.all

      # Verify we got both prompts
      assert_equal 2, prompts.count
      prompt_names = prompts.map(&:name)
      assert_includes prompt_names, "prompt1"
      assert_includes prompt_names, "prompt2"
    end
  end
end
