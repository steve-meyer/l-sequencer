# l-sequencer

A Max grid sequencer for branching Lindenmayer System strings.

## Installation

Download or clone this repository and save it in your Max `Packages` directory/folder as `l-sequencer`. An **l-sequencer** entry will then show up in the Max Package Manager under **Installed Packages**.

## Overview

The primary l-sequencer object `[lsq.sequencer]` is a Max abstraction that takes L-system strings as input and processes them first through an L-system rule set to generate a new string and then translates the new string into one or more sequencer steps to be played back. The core data model of this sequencer can be understood as a 2-dimensional matrix. The columns of the matrix represent the sequencer steps and the rows represent simultaneous events for a given step.

For example, consider a matrix in which step N is a column that contains event symbols F, X and Y in rows 1, 2 and 3 respectively. Those events could be translated into note pitches (e.g., MIDI note numbers) by a processing algorithm/interpreter that receives the sequencer's output. Because all three notes are received simultaneously as part of the same sequencer step, in this instance step N would represent a chord or polyphony.

The interpretation of sequencer output is left to the process consuming its step data. Whether the symbols produced by the sequencer are interpreted as traditional sequencer data (note/pitch) or whether they represent other musical parameters (e.g., timbre as MIDI program) or the initiation of a more complex event/process, each symbol is only intended to stand in for an event in the most general sense. The composer is therefore encouraged to consider this sequencer as a representation of macro, rather than micro/atomic, compositional elements.

## Symbols

There are three types of symbols available.

* **Event Symbols:** Any single character that is not a branching or metadata symbol. These are understood as sequencer events.
* **Branching Symbols:** `[` and `]`
  * Start branch (`[`): indicates the next stream of event symbols will begin a sequence that starts simultaneous to the immediately preceding event symbol (branch parent) until the branch terminates
  * Terminate branch (`]`): indicates a branch is complete and will return the step position to the succeeding step after the branch parent
* **Metadata Symbols:** `+` and `-`. These symbols will be paired with the succeeding event symbol. Multiple successive metadata symbols can occur and the entire sequence will be paired with the succeeding event symbol. Metadata symbols are optional and do not need to be included with each event. These are understood as parametric changes that should be applied prior to a paired event.

## Testing

This Max Package is tested using the Ruby RSpec framework. See the `spec` directory for the test suite, which is kinda funny, right? Here's how it works...

### Ruby Dependencies

Your computer will need Ruby installed and the following gems (Ruby's word for 3rd party libraries):

1. [RSpec](https://github.com/rspec/rspec-metagem): the testing framework
2. [OSC Ruby](https://github.com/aberant/osc-ruby): a Ruby client for communicating via OSC

### Overview

All interaction between Ruby and Max is done over an Open Sound Control (OSC) network. Max can receive and send OSC messages via the `[udpsend]` and `[udpreceive]` objects.

To run the tests, first open the Max patcher file in the location:

`{PACKAGE_ROOT}/spec/support/test_controller.maxpat`

This file acts as a kind of central server for loading the test mocks. Ruby communicates with it by sending basic messages to open specific patcher files that the tests interact with.

Once this file is open, you can run the test suite at the command line:

```bash
~/Documents/Max 8/Packages/l-sequencer $ open spec/support/test_controller.maxpat
~/Documents/Max 8/Packages/l-sequencer $ rspec spec/lsq_interpreter_spec.rb

L-Sequencer Interpreter
  when loading the default [lsq.interpreter]
    has a default set of rules
    does not have a current string
    when sending it a one character axiom
      does have a current string
      'l-string' is an alias for 'axiom'
    a multi-character axiom
      produces a more complex l-system string
    when managing rules
      can add a rule
      can delete a rule
    when evolving a string
      has an initial string based on the first rule
      'advance' msg process the current string according to the production rules
      can keep advancing

Finished in 5.34 seconds (files took 0.12029 seconds to load)
10 examples, 0 failures
```

The test suite is relatively slow because there are intentional pauses to make sure that the Ruby side of things has time to receive responses back from Max.

Note that when the tests run, the mock patchers will be opened and closed, usually pretty quickly. Ruby sends OSC messages over the localhost network. The `test_controller.maxpat` is responsible for coordinating creating and tearing down the mocks.

The subsequently opened Max patchers that act as mocks have `[udpreceive]` objects listening for messages that are passed onto the L-Sequencer objects. The output of those objects is sent back to Ruby via the `[udpsend]` objects where Ruby has an in-memory UDP Server listening for Max's responses. After that point, all data has been gathered and the standard unit/functional test assertions can operate as they always do.

**Important:** note that the tests assume that the patcher mocks are opened before the test suites run and close right after. The tests themselves change state and are written to test initial state and the state changes in response to receiving messages.

## Acknowledgments & Inspiration

This set of Max abstractions are inspired by [R. Luke DuBois' dissertation](https://www.lukedubois.com/projects-1/diss). While there are Max packages like cage that will implement L-system string rewriting algorithms, `l-sequencer` is focused on interpreting a branching L-system string into a data structure that represents simultaneous, or co-occurring, events. DuBois provides an interpretation of L-system branching that translates a melodic event sequence into harmony or polyphony.
