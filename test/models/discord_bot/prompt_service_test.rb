require "test_helper"

module DiscordBot
  class PromptServiceTest < ActiveSupport::TestCase
    setup do
      @prompt_service = PromptService.new
      # Clear any existing prompts before each test
      Prompt.destroy_all
    end

    test "create adds a new prompt" do
      prompt = @prompt_service.create("test_prompt", "This is a test prompt")
      assert_equal "test_prompt", prompt.name
      assert_equal "This is a test prompt", prompt.content
      assert_equal 1, Prompt.count
    end

    test "find_by_name returns the correct prompt" do
      @prompt_service.create("test_prompt", "This is a test prompt")
      prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal "test_prompt", prompt.name
      assert_equal "This is a test prompt", prompt.content
    end

    test "find_by_name returns nil for non-existent prompt" do
      prompt = @prompt_service.find_by_name("non_existent")
      assert_nil prompt
    end

    test "all returns all prompts" do
      @prompt_service.create("prompt1", "Content 1")
      @prompt_service.create("prompt2", "Content 2")
      prompts = @prompt_service.all
      assert_equal 2, prompts.count
      assert_equal ["prompt1", "prompt2"], prompts.map(&:name).sort
    end

    test "update changes prompt content" do
      @prompt_service.create("test_prompt", "Original content")
      updated_prompt = @prompt_service.update("test_prompt", "Updated content")
      assert_equal "Updated content", updated_prompt.content
      
      # Verify the change persisted
      prompt = @prompt_service.find_by_name("test_prompt")
      assert_equal "Updated content", prompt.content
    end

    test "update returns nil for non-existent prompt" do
      result = @prompt_service.update("non_existent", "New content")
      assert_nil result
    end

    test "delete removes a prompt" do
      @prompt_service.create("test_prompt", "Content")
      assert_equal 1, Prompt.count
      
      result = @prompt_service.delete("test_prompt")
      assert_equal true, result
      assert_equal 0, Prompt.count
    end

    test "delete returns false for non-existent prompt" do
      result = @prompt_service.delete("non_existent")
      assert_equal false, result
    end
  end
end 