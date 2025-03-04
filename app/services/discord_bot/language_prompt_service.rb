module DiscordBot
  class LanguagePromptService
    SUPPORTED_LANGUAGES = {
      "english" => "en",
      "spanish" => "es",
      "french" => "fr",
      "german" => "de",
      "italian" => "it",
      "portuguese" => "pt",
      "japanese" => "ja",
      "chinese" => "zh",
      "korean" => "ko",
      "russian" => "ru"
    }

    def initialize(prompt_service)
      @prompt_service = prompt_service
    end

    def detect_language(channel_name, message_content)
      # First try to detect from channel name
      SUPPORTED_LANGUAGES.each do |language_name, code|
        return code if channel_name.to_s.downcase.include?(language_name)
      end

      # If no language detected from channel name, try to detect from message content
      # This is a simple implementation - in a real-world scenario, you might want to use
      # a more sophisticated language detection library
      nil
    end

    def get_practice_prompt(language_code, difficulty = "intermediate")
      prompt_name = "language_practice_#{language_code}_#{difficulty}"
      prompt = @prompt_service.find_by_name(prompt_name)

      # If no specific prompt exists for this language and difficulty, fall back to default
      unless prompt
        prompt = @prompt_service.find_by_name("language_practice_default")
        return create_default_prompt(language_code, difficulty) unless prompt
      end

      prompt.content
    end

    def create_default_prompts
      create_default_prompt("en", "beginner")
      create_default_prompt("en", "intermediate")
      create_default_prompt("en", "advanced")

      create_default_prompt("es", "beginner")
      create_default_prompt("es", "intermediate")
      create_default_prompt("es", "advanced")

      # Add more languages as needed

      create_general_default_prompt
    end

    private

    def create_default_prompt(language_code, difficulty)
      language_name = SUPPORTED_LANGUAGES.key(language_code) || "unknown"
      prompt_name = "language_practice_#{language_code}_#{difficulty}"

      content = case difficulty
      when "beginner"
        "You are a helpful #{language_name.capitalize} language tutor for beginners. " \
        "Use simple vocabulary and basic grammar. " \
        "Provide translations for new words. " \
        "Correct mistakes gently and explain basic grammar concepts. " \
        "Keep responses short and focused on practical, everyday topics."
      when "intermediate"
        "You are a supportive #{language_name.capitalize} language tutor for intermediate learners. " \
        "Use a mix of simple and more complex vocabulary and grammar. " \
        "Correct mistakes and explain grammar concepts when relevant. " \
        "Encourage more complex responses and introduce idiomatic expressions. " \
        "Discuss a variety of topics including culture, current events, and personal interests."
      when "advanced"
        "You are a #{language_name.capitalize} language tutor for advanced learners. " \
        "Use sophisticated vocabulary, complex grammar, and idiomatic expressions. " \
        "Correct subtle mistakes and discuss nuanced grammar points. " \
        "Engage in deep conversations about complex topics. " \
        "Introduce cultural nuances, literature, and specialized vocabulary."
      else
        "You are a helpful #{language_name.capitalize} language tutor. " \
        "Adapt your language level to the user's proficiency. " \
        "Correct mistakes when appropriate and explain grammar concepts. " \
        "Engage in conversation about various topics to help the user practice."
      end

      @prompt_service.create(prompt_name, content)
      content
    end

    def create_general_default_prompt
      content = "You are a helpful language tutor. " \
                "Detect the language being used in the conversation and adapt accordingly. " \
                "If the user is practicing a language, help them improve by correcting mistakes " \
                "and suggesting better ways to express their ideas. " \
                "Adapt your language level to match the user's proficiency. " \
                "If the user asks for help with a specific language task, provide clear guidance."

      @prompt_service.create("language_practice_default", content)
    end
  end
end
