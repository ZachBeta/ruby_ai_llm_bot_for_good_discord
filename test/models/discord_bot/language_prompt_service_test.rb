require "test_helper"

module DiscordBot
  class LanguagePromptServiceTest < ActiveSupport::TestCase
    setup do
      @prompt_service = PromptService.new
      @language_prompt_service = LanguagePromptService.new(@prompt_service)
      # Clear any existing prompts before each test
      Prompt.destroy_all
    end

    test "detect_language from channel name" do
      # Test detection from channel names
      assert_equal "es", @language_prompt_service.detect_language("spanish-practice", "")
      assert_equal "fr", @language_prompt_service.detect_language("french_learning", "")
      assert_equal "de", @language_prompt_service.detect_language("german-chat", "")
      assert_equal "ja", @language_prompt_service.detect_language("japanese-beginners", "")
      assert_nil @language_prompt_service.detect_language("general-chat", "")
    end

    test "create_default_prompt for different languages and difficulties" do
      # Test creating default prompts for different languages and difficulties
      en_beginner = @language_prompt_service.create_default_prompt("en", "beginner")
      assert_includes en_beginner, "English"
      assert_includes en_beginner, "beginner"
      
      es_intermediate = @language_prompt_service.create_default_prompt("es", "intermediate")
      assert_includes es_intermediate, "Spanish"
      assert_includes es_intermediate, "intermediate"
      
      fr_advanced = @language_prompt_service.create_default_prompt("fr", "advanced")
      assert_includes fr_advanced, "French"
      assert_includes fr_advanced, "advanced"
      
      # Verify prompts were created in the database
      assert_not_nil @prompt_service.find_by_name("language_practice_en_beginner")
      assert_not_nil @prompt_service.find_by_name("language_practice_es_intermediate")
      assert_not_nil @prompt_service.find_by_name("language_practice_fr_advanced")
    end

    test "create_default_prompts creates multiple prompts" do
      # Test creating all default prompts
      @language_prompt_service.create_default_prompts
      
      # Check that default prompts were created
      assert_not_nil @prompt_service.find_by_name("language_practice_en_beginner")
      assert_not_nil @prompt_service.find_by_name("language_practice_en_intermediate")
      assert_not_nil @prompt_service.find_by_name("language_practice_en_advanced")
      
      assert_not_nil @prompt_service.find_by_name("language_practice_es_beginner")
      assert_not_nil @prompt_service.find_by_name("language_practice_es_intermediate")
      assert_not_nil @prompt_service.find_by_name("language_practice_es_advanced")
      
      assert_not_nil @prompt_service.find_by_name("language_practice_default")
    end

    test "get_practice_prompt returns correct prompt" do
      # Create a test prompt
      @prompt_service.create("language_practice_es_intermediate", "Test Spanish intermediate prompt")
      
      # Test getting the prompt
      prompt = @language_prompt_service.get_practice_prompt("es", "intermediate")
      assert_equal "Test Spanish intermediate prompt", prompt
    end

    test "get_practice_prompt creates default prompt if not found" do
      # Test getting a prompt that doesn't exist yet
      prompt = @language_prompt_service.get_practice_prompt("de", "beginner")
      
      # Verify a default prompt was created
      assert_includes prompt, "German"
      assert_includes prompt, "beginner"
      
      # Verify it was saved to the database
      assert_not_nil @prompt_service.find_by_name("language_practice_de_beginner")
    end
  end
end 