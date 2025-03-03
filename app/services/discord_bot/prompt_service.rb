module DiscordBot
  class PromptService
    def initialize
      # No initialization needed
    end

    def create(name, content)
      Prompt.create(name: name, content: content)
    end

    def find_by_name(name)
      Prompt.find_by(name: name)
    end

    def all
      Prompt.all
    end

    def update(name, new_content)
      prompt = find_by_name(name)
      return nil unless prompt

      prompt.update(content: new_content)
      prompt
    end

    def delete(name)
      prompt = find_by_name(name)
      return false unless prompt

      prompt.destroy
      true
    end
  end
end 