require "osc-ruby"
require "osc-ruby/em_server"


RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


def controller_client
  @controller_client ||= OSC::Client.new("localhost", 7474)
end


def client
  @client ||= OSC::Client.new("localhost", 7400)
end


def server
  @server ||= OSC::Server.new(7401)
end


def mock_dir
  File.join(File.expand_path(File.dirname(__FILE__)), "support")
end


# Send a message to the [udpreceive] object in Max, then wait briefly for it to respond
# back to the OSC::Server in the spec
def send_message(client, msg)
  client.send( OSC::Message.new(*msg) )
  sleep(0.25)
end
