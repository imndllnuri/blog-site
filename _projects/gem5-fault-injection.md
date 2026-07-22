---
title: gem5 Fault Injection
summary: A fork of the gem5 architecture simulator adding a deterministic single-bit register fault injector for RISC-V, used to study CPU soft-error resiliency.
tech: [C++, Python, SCons, gem5]
type: Research
category: Research
tags: [Computer Architecture, Research]
highlight: Deterministic single-bit fault injection with automated campaign sweeps
repo: https://github.com/imndllnuri/riscv-gem5-fault-injector
demo:
order: 2
---

## Overview

Adds a `FaultInjector` SimObject to gem5's RISC-V `AtomicSimpleCPU`/
`TimingSimpleCPU` models that flips a single bit in a register at a precise
cycle, so the resulting crash / silent corruption / no-effect outcome can be
observed and classified. Built on top of a full gem5 checkout — the fault
injector itself (`src/cpu/simple/fault_injector.{hh,cc,py}`) and a handful of
integration points in `src/cpu/simple/*` are the original work; everything
else is upstream gem5.

## Motivation

Soft errors — a cosmic ray or electrical noise flipping a single bit in a
register or memory cell — are a real reliability concern for CPUs, especially
at smaller process nodes and in radiation-heavy environments (aerospace, high
altitude, nuclear). Studying their effect on real silicon means waiting for
one to happen, which is not a practical way to do research. A cycle-accurate
simulator, on the other hand, lets you *choose* exactly which bit, in which
register, at which cycle, gets flipped, and then simply look at what the
program does next — crash, silently produce a wrong answer, or recover
without any visible effect. That controllability is the whole point of
building this on gem5 instead of trying to observe faults on real hardware.

## Architecture / how it works

The `FaultInjector` SimObject takes four parameters — `enabled`, `reg_index`
(x0–x31), `bit_pos` (0–63), and `inject_cycle` — and is wired into gem5's
simple CPU models two different ways depending on which CPU type is
simulated:

- **`AtomicSimpleCPU`**: polls every tick, checking whether the current cycle
  matches `inject_cycle`, since Atomic mode doesn't have a native
  fine-grained event/tick abstraction to hook into.
- **`TimingSimpleCPU`**: schedules a one-shot gem5 event for the exact
  injection cycle instead of polling, which fits Timing mode's
  event-driven execution model more naturally.

Running with `--debug-flags=FaultTrace` dumps the target register's value
immediately before and after the injected flip, so a single run can be
inspected by hand. For anything beyond a single run, `fault-injection/
run_campaign.py` automates the actual experiment: it first does a **golden
run** (no fault) to learn how many cycles the program takes, splits that
duration into intervals, then runs randomized (register, bit, cycle)
combinations per interval — resumable and parallelizable across workers, so
a campaign can be stopped and restarted, or split across multiple machines,
without losing progress.

## Key design decisions

**Why two different injection mechanisms for Atomic vs. Timing CPU?** Because
gem5's two simple-CPU models have fundamentally different internal execution
models — Atomic mode executes a whole instruction "atomically" per tick with
no fine-grained event scheduling to hook into, while Timing mode is built
around scheduled events. Reusing a single mechanism for both would have meant
either polling in Timing mode too (wasteful, since it already has an event
system) or trying to force one-shot events into Atomic mode (nothing to
schedule against). Matching the injection mechanism to each CPU model's own
execution style kept both integrations simple instead of forcing one design
to fit both.

**Why golden-run-first, randomized-sweep campaigns instead of exhaustive
testing?** Exhaustively testing every (register × bit × cycle) combination
for a program running millions of cycles is combinatorially infeasible.
Learning the golden-run cycle count first, then sampling randomly within
that space per interval, gives statistically meaningful coverage of "does a
fault in this phase of execution tend to crash, corrupt silently, or do
nothing" without needing to enumerate every possibility.

## Results

Two kinds of results came out of this: a small demo campaign against a
`towers5` RISC-V binary (4 registers × 2 intervals, in `fault-injection/
run_demo.sh`), and a much larger sweep against SPEC CPU2017 benchmarks
(qsort, sieve, matmul, xalancbmk, radix, merge, LUDecomp, specrand) across
both CPU models. Each individual run records a `fi_meta.txt` with the exact
register/bit/cycle used and the outcome — e.g. a fault at bit 31 of register
4, injected at cycle 114963 of a 148408-cycle interval, completing in 0.6s
with status `SUCCESS` (meaning the program ran to completion despite the
flip — a "silent" case worth investigating further, not necessarily a
correct one).

The SPEC sweep's aggregate visualizations are the more interesting artifacts:

![Combined outcome summary across SPEC benchmarks](/assets/img/projects/gem5-fault-injection/combined-outcome-summary.png)
_Outcome classification (crash / silent corruption / no effect) aggregated across all SPEC benchmarks._

![Fault outcome heatmap by bit position and cycle](/assets/img/projects/gem5-fault-injection/spec-heatmap.png)
_Where in a program's execution — and which bit positions — faults are most likely to be consequential._

![Bit position vs. injection cycle scatter, colored by outcome](/assets/img/projects/gem5-fault-injection/bit-cycle-scatter.png)
_Every injected fault plotted by bit position and cycle, colored by outcome — visible clustering shows some execution phases are much more fault-sensitive than others._

![Fault outcome heatmap for the Towers-of-Hanoi demo workload](/assets/img/projects/gem5-fault-injection/towers-fault-heatmap.png)
_The same kind of analysis on the smaller `towers5` demo benchmark, useful as a quick sanity check against the full SPEC sweep._

## Links

- [Source code]({{ page.repo }})
