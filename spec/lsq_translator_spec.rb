require "spec_helper"


RSpec.describe "L-Sequencer Translator" do
  before(:all)  { start_server(7402) }
  after(:all)   { stop_server }

  context "the [lsq.translator] Max abstraction" do
    before(:all) do
      @patcher_sym  = random_symbol
      open_mock("lsq.translator", @patcher_sym)
    end

    after(:all) do
      close_mock(@patcher_sym)
    end

    context "when it receives a single symbol l-string" do
      before(:all) do
        clear_outputs(:multi_valued)
        send_message(client, "F")
        @output = @out1
      end

      it "produces a single output" do
        expect(@output.size).to eq(1)
      end

      it "contains a single set of value and matrix coordinates" do
        expect(@output.first.size).to eq(4)
      end

      it "translates the symbol to a unicode code point" do
        expect(@output.first.first).to eq(70)
      end

      it "contains matrix coordinates for cell in row 1, column 1, plane 1" do
        expect(@output.first[1..-1]).to eq([0, 0, 0])
      end
    end


    context "when it receives an l-string with one metadata symbol and one event symbol" do
      before(:all) do
        clear_outputs(:multi_valued)
        send_message(client, "+ F")
        @output = @out1
      end

      it "produces a two outputs" do
        expect(@output.size).to eq(2)
      end

      it "contains a two sets of value and matrix coordinates" do
        expect(@output[0].size).to eq(4)
        expect(@output[1].size).to eq(4)
      end

      it "translates the event symbol to a unicode code point" do
        expect(@output[1][0]).to eq(70)
      end

      it "contains matrix coordinates for cell in row 1, column 1, plane 1" do
        expect(@output[1][1..-1]).to eq([0, 0, 0])
      end

      it "converts the metadata symbol to a binary representation and then translate it to decimal" do
        expect(@output[0][0]).to eq(1)
      end

      it "contains matrix coordinates for cell in row 1, column 1, plane 2" do
        expect(@output[0][1..-1]).to eq([0, 0, 1])
      end
    end


    context "when it receives a string with multiple metadata symbols" do
      before(:all) do
        clear_outputs(:multi_valued)
        send_message(client, "+ - + F")
        @output = @out1
      end

      it "produces a two outputs (successive metadata symbols are combined)" do
        expect(@output.size).to eq(2)
      end

      it "contains a two sets of value and matrix coordinates" do
        expect(@output[0].size).to eq(4)
        expect(@output[1].size).to eq(4)
      end

      it "converts the metadata symbol to a binary representation and then translate it to decimal" do
        # "+ - +" converts to "101" in binary, which is 5 in decimal
        expect(@output[0][0]).to eq(5)
      end

      it "contains matrix coordinates for cell in row 1, column 1, plane 2" do
        expect(@output[0][1..-1]).to eq([0, 0, 1])
      end
    end


    context "when it receives a string with branching symbols" do
      before(:all) do
        clear_outputs(:multi_valued)
        send_message(client, "F [ + - + X ]")
        @output = @out1
      end

      it "produces outputs for event and metadata symbols only (branching symbols create simultaneity)" do
        expect(@output.size).to eq(3)
      end

      it "contains a three sets of value and matrix coordinates" do
        expect(@output[0].size).to eq(4)
        expect(@output[1].size).to eq(4)
        expect(@output[2].size).to eq(4)
      end

      it "translates the event symbols to unicode code points" do
        expect(@output[0][0]).to eq(70)
        expect(@output[2][0]).to eq(88)
      end

      it "has event matrix coordinates for in plane 1" do
        expect(@output[0][3]).to eq(0)
        expect(@output[2][3]).to eq(0)
      end

      it "puts the branched event in row 2" do
        expect(@output[2][2]).to eq(1)
      end

      it "pairs the metadata symbols with the appropriate branch" do
        expect(@output[1][0]).to eq(5) # decimal-of-binary for "+ - +"
        expect(@output[1][1]).to eq(0) # column 1
        expect(@output[1][2]).to eq(1) # row 2
        expect(@output[1][3]).to eq(1) # plane 2
      end
    end


    context "when there are events after a branch terminates" do
      before(:all) do
        clear_outputs(:multi_valued)
        send_message(client, "F [ X ] Y")
        @output = @out1
      end

      it "produces outputs for events only (branching symbols create simultaneity)" do
        expect(@output.size).to eq(3)
      end

      it "places the post-branch event in the next column" do
        expect(@output[2]).to eq([89, 1, 0, 0])
      end
    end
  end
end
