require "spec_helper"


RSpec.describe "L-Sequencer Interpreter" do
  context "when loading the default [lsq.interpreter]" do
    before(:all) do
      @patcher_path = File.join(mock_dir, "lsq.interpreter_mock.maxpat")
      @patcher_sym  = (0...8).map { (65 + rand(26)).chr }.join
      send_message(controller_client, ["/openfile", @patcher_sym, @patcher_path])

      @server  = OSC::Server.new(7401)
      @srv_thr = Thread.new { @server.run }
    end

    after(:all) do
      send_message(controller_client, ["/closefile", @patcher_sym])
      @srv_thr.exit
    end

    before(:each) do
      @out1 = nil
      @out2 = Array.new
      @server.add_method("/out1") {|message| @out1  = message.to_a}
      @server.add_method("/out2") {|message| @out2 << message.to_a}
    end

    it "has a default set of rules" do
      send_message(client, "rules")
      expected = [
        ["F", "=>", "+", "+", "F", "Y"],
        ["Y", "=>", "-", "F", "[", "X", "]", "[", "-", "Y", "+", "F", "]"],
        ["X", "=>", "X", "[", "F", "+", "Y", "]"]
      ]
      expect(@out2).to eq(expected)
    end

    it "does not have a current string" do
      send_message(client, "get")
      expect(@out1).to be_nil
    end


    context "when sending it a one character axiom" do
      before(:all) do
        send_message(client, "axiom F")
      end

      it "does have a current string" do
        send_message(client, "get")
        expect(@out1).not_to be_nil
        expect(@out1).to eq(["+", "+", "F", "Y"])
      end

      it "'l-string' is an alias for 'axiom'" do
        send_message(client, "axiom F")
        expect(@out1).to eq(["+", "+", "F", "Y"])
      end
    end


    context "a multi-character axiom" do
      it "produces a more complex l-system string" do
        send_message(client, "axiom F X Y")
        expect(@out1).to eq(["+", "+", "F", "Y", "X", "[", "F", "+", "Y", "]", "-", "F", "[", "X", "]", "[", "-", "Y", "+", "F", "]"])
      end
    end


    context "when managing rules" do
      before(:all) do
        send_message(client, "rule D F [ X ]")
      end

      it "can add a rule" do
        send_message(client, "rules")
        expect(@out2).to include(["D", "=>", "F", "[", "X", "]"])
      end

      it "can delete a rule" do
        send_message(client, "deleterule D")
        send_message(client, "rules")
        expect(@out2).not_to include(["D", "=>", "F", "[", "X", "]"])
      end
    end


    context "when evolving a string" do
      before(:all) do
        send_message(client, "deleterule F")
        send_message(client, "deleterule X")
        send_message(client, "deleterule Y")
        send_message(client, "rule A B")
        send_message(client, "rule B A C")
        send_message(client, "axiom A")
      end

      it "has an initial string based on the first rule" do
        send_message(client, "get")
        expect(@out1).to eq(["B"])
      end

      it "'advance' msg process the current string according to the production rules" do
        send_message(client, "advance")
        expect(@out1).to eq(["A", "C"])
      end

      it "can keep advancing" do
        send_message(client, "advance")
        expect(@out1).to eq(["B", "C"])
      end
    end
  end
end
