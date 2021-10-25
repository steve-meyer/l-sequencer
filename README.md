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

## Acknowledgments & Inspiration

This set of Max abstractions are inspired by [R. Luke DuBois' dissertation](https://www.lukedubois.com/projects-1/diss). While there are Max packages like cage that will implement L-system string rewriting algorithms, `l-sequencer` is focused on interpreting a branching L-system string into a data structure that represents simultaneous, or co-occurring, events. DuBois provides an interpretation of L-system branching that translates a melodic event sequence into harmony or polyphony.
