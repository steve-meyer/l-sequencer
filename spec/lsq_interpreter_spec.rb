require "spec_helper"


RSpec.describe "L-Sequencer Interpreter" do
  before(:all)  { start_server  }
  after(:all)   { stop_server   }
  before(:each) { clear_outputs }

  context "when loading the default [lsq.interpreter]" do
    before(:all) do
      @patcher_sym  = random_symbol
      open_mock("lsq.interpreter", @patcher_sym)
    end

    after(:all) do
      close_mock(@patcher_sym)
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


  context "an l-system with single character (non-list) production rules" do
    before(:all) do
      @patcher_sym  = random_symbol
      open_mock("lsq.interpreter", @patcher_sym)

      send_message(client, "rule F X")
      send_message(client, "rule X Y")
      send_message(client, "rule Y F")
      send_message(client, "axiom F")
    end

    after(:all) do
      close_mock(@patcher_sym)
    end

    it "should not include the 'symbol' in the output" do
      send_message(client, "get")
      expect(@out1).not_to include("symbol")
    end

    it "should have a string processed by the production rules" do
      send_message(client, "get")
      expect(@out1).to eq(["X"])
    end

    context "after advancing" do
      before(:all) do
        send_message(client, "advance")
      end

      it "should not include the 'symbol' in the output" do
        send_message(client, "get")
        expect(@out1).not_to include("symbol")
      end

      it "should have an l-string for the next iteration" do
        send_message(client, "get")
        expect(@out1).to eq(["Y"])
      end
    end
  end
end
