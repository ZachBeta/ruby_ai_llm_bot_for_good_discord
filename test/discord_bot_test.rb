require_relative 'test_helper'

class DiscordBotTest < Minitest::Test
  def setup
    # Mock the Discord bot
    @mock_bot = mock('DiscordBot')
    Discordrb::Bot.stubs(:new).returns(@mock_bot)
    
    # Mock the setup methods
    @mock_bot.stubs(:message)
    @mock_bot.stubs(:run)
    @mock_bot.stubs(:send_message)
    
    # Mock environment variables
    ENV['DISCORD_TOKEN'] ||= 'fake_token'
    ENV['DISCORD_CHANNEL_ID'] ||= 'fake_channel_id'
    ENV['OPENROUTER_API_KEY'] ||= 'fake_api_key'
    
    # Mock Listen gem to prevent auto-reload during tests
    @mock_listener = mock('Listener')
    Listen.stubs(:to).returns(@mock_listener)
    @mock_listener.stubs(:start)
    
    # Create the bot instance after mocking
    @bot = DiscordBot.new
  end
  
  def test_initialization_creates_llm_client
    assert_instance_of LlmClient, @bot.instance_variable_get(:@llm)
  end
  
  def test_send_to_channel_calls_bot_send_message
    channel_id = '123456'
    message = 'Test message'
    
    @mock_bot.expects(:send_message).with(channel_id, message)
    @bot.send_to_channel(channel_id, message)
  end
  
  def test_start_calls_bot_run
    @mock_bot.expects(:run)
    @bot.start
  end
  
  def test_setup_commands_registers_debug_command
    # Reset mocks to verify specific interactions
    @mock_bot = mock('DiscordBot')
    Discordrb::Bot.stubs(:new).returns(@mock_bot)
    
    # Expect the debug command to be registered
    @mock_bot.expects(:message).with(start_with: '!debug').once.yields(mock_event)
    
    # Mock other setup methods
    @mock_bot.stubs(:message).with(start_with: '!clear')
    @mock_bot.stubs(:message).with {|args| args.nil? }
    @mock_bot.stubs(:send_message)
    
    # Recreate bot with new expectations - use underscore to indicate unused variable
    _new_bot = DiscordBot.new
  end
  
  def test_setup_commands_registers_clear_command
    # Reset mocks to verify specific interactions
    @mock_bot = mock('DiscordBot')
    Discordrb::Bot.stubs(:new).returns(@mock_bot)
    
    # Expect the clear command to be registered
    @mock_bot.expects(:message).with(start_with: '!clear').once.yields(mock_event)
    
    # Mock other setup methods
    @mock_bot.stubs(:message).with(start_with: '!debug')
    @mock_bot.stubs(:message).with {|args| args.nil? }
    @mock_bot.stubs(:send_message)
    
    # Recreate bot with new expectations - use underscore to indicate unused variable
    _new_bot = DiscordBot.new
  end
  
  def test_message_handler_processes_user_mentions
    # Mock the bot with a message handler
    @mock_bot = mock('DiscordBot')
    Discordrb::Bot.stubs(:new).returns(@mock_bot)
    
    # Create a more comprehensive mock event
    event = mock_event_with_mention
    
    # Mock user lookup
    mock_user = mock('User')
    mock_user.stubs(:name).returns('TestUser')
    @mock_bot.stubs(:user).with(123456).returns(mock_user)
    
    # Expect the LLM client to be called with the processed message
    mock_llm = mock('LlmClient')
    LlmClient.stubs(:new).returns(mock_llm)
    mock_llm.expects(:generate_response).with(includes('TestUser'), any_parameters).at_least_once.returns('Test response')
    
    # Setup message handler expectation
    @mock_bot.stubs(:message).with(start_with: '!debug')
    @mock_bot.stubs(:message).with(start_with: '!clear')
    @mock_bot.expects(:message).with {|args| args.nil? }.once.yields(event)
    @mock_bot.stubs(:send_message)
    
    # Create bot instance to trigger the handler - use underscore to indicate unused variable
    _new_bot = DiscordBot.new
  end
  
  def test_auto_reload_setup
    # Need to temporarily disable the TESTING environment variable
    old_testing = ENV['TESTING']
    ENV['TESTING'] = nil
    
    # This is mainly testing that our mocks prevent actual file listeners
    Listen.expects(:to).with('.').returns(@mock_listener)
    @mock_listener.expects(:start)
    
    # Reset mocks and create a new bot to trigger setup_auto_reload
    @mock_bot = mock('DiscordBot')
    Discordrb::Bot.stubs(:new).returns(@mock_bot)
    @mock_bot.stubs(:message)
    @mock_bot.stubs(:send_message)
    
    # Use underscore to indicate unused variable
    _new_bot = DiscordBot.new
    
    # Restore the environment variable
    ENV['TESTING'] = old_testing
  end
  
  private
  
  def mock_event
    event = mock('Event')
    channel = mock('Channel')
    message = mock('Message')
    user = mock('User')
    thread = mock('Thread')
    server = mock('Server')
    
    event.stubs(:channel).returns(channel)
    event.stubs(:message).returns(message)
    event.stubs(:user).returns(user)
    event.stubs(:timestamp).returns(Time.now)
    event.stubs(:content).returns('!test message')
    event.stubs(:respond)
    event.stubs(:server).returns(server)
    
    channel.stubs(:id).returns('test_channel')
    channel.stubs(:name).returns('test_channel_name')
    
    message.stubs(:id).returns('test_message_id')
    message.stubs(:thread).returns(thread)
    
    thread.stubs(:id).returns('test_thread_id')
    
    user.stubs(:id).returns('test_user_id')
    user.stubs(:name).returns('test_user')
    
    server.stubs(:id).returns('test_server_id')
    server.stubs(:name).returns('test_server')
    
    event
  end
  
  def mock_event_with_mention
    event = mock_event
    event.stubs(:content).returns('!hey <@123456> how are you?')
    event
  end
end 