require "osc-ruby"


RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


# The "server" is an OSC listener that will catch messages sent from Max in response to
# sending OSC messages that will trigger functionality to be tested.
def start_server
  @server  = OSC::Server.new(7401)
  @srv_thr = Thread.new { @server.run }
end


def stop_server
  @srv_thr.exit
end


# The outN variables here simply represent the output received from Max abstraction outlets.
# See for example how the outlets are wired up to [udpsend] objects in the file
# lsq.interpreter_mock.maxpat
def clear_outputs
  @out1 = nil
  @out2 = Array.new
  @server.add_method("/out1") {|message| @out1  = message.to_a}
  @server.add_method("/out2") {|message| @out2 << message.to_a}
end


# Send a message to the [udpreceive] object in Max, then wait briefly for it to respond
# back to the OSC::Server in the spec
def send_message(client, msg)
  client.send( OSC::Message.new(*msg) )
  sleep(0.25)
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


def random_symbol
  (0...8).map { (65 + rand(26)).chr }.join
end


def open_mock(object, patcher_sym)
  mock = File.join(mock_dir, "#{object}_mock.maxpat")
  send_message(controller_client, ["/openfile", patcher_sym, mock])
end


def close_mock(patcher_sym)
  send_message(controller_client, ["/closefile", patcher_sym])
end
