module DiscordBot
  class PromptService
    def initialize
      # No initialization needed
    end

    def create(name, content, channel_id = nil)
      Prompt.create(name: name, content: content, channel_id: channel_id)
    end

    def find_by_name(name, channel_id = nil)
      if channel_id
        # First try to find a channel-specific prompt
        prompt = Prompt.find_by(name: name, channel_id: channel_id)
        # If not found, fall back to global prompt (nil channel_id)
        prompt ||= Prompt.find_by(name: name, channel_id: nil)
      else
        # Only look for global prompts
        Prompt.find_by(name: name, channel_id: nil)
      end
    end

    def all(channel_id = nil)
      if channel_id
        # Return both channel-specific and global prompts
        Prompt.where(channel_id: [channel_id, nil])
      else
        # Return only global prompts
        Prompt.where(channel_id: nil)
      end
    end

    def update(name, new_content, channel_id = nil)
      prompt = find_by_name(name, channel_id)
      return nil unless prompt

      prompt.update(content: new_content)
      prompt
    end

    def delete(name, channel_id = nil)
      prompt = find_by_name(name, channel_id)
      return false unless prompt

      prompt.destroy
      true
    end
  end
end
