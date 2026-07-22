---
title: "Injecting Faults into gem5: Studying CPU Soft-Error Resiliency"
date: 2026-07-22 10:00:00 +0300
categories: [Research]
tags: [Computer Architecture, Research]
---

A cosmic ray or a bit of electrical noise flipping a single bit in a
register is a real reliability concern for CPUs — more so at smaller
process nodes, and especially in radiation-heavy environments like
aerospace or high-altitude flight. The problem with studying it on real
hardware is that you have to wait for a fault to happen, and even then you
don't get to choose which bit, in which register, at which cycle. A
cycle-accurate simulator removes that constraint entirely: you pick the
exact conditions and just watch what the program does next. That's the
whole premise behind this project — a fork of
[gem5](https://www.gem5.org/) that adds a deterministic, single-bit fault
injector to its RISC-V simple-CPU models.

## Where the fault injector actually lives

The core addition is a `FaultInjector` SimObject with four parameters —
`enabled`, `reg_index` (x0–x31), `bit_pos` (0–63), and `inject_cycle` — wired
into gem5's `AtomicSimpleCPU` and `TimingSimpleCPU` models. It's wired in
*differently* for each, because the two models don't share an execution
style: `AtomicSimpleCPU` executes a whole instruction per tick with no
fine-grained event abstraction to hook into, so the injector polls every
tick and checks whether the current cycle matches the target. `TimingSimpleCPU`
is built around scheduled events, so the injector schedules a single one-shot
event for the exact injection cycle instead. Trying to force one mechanism
onto both models would have meant either wasteful polling in Timing mode (which
already has an event system) or nothing to schedule against in Atomic mode —
matching the mechanism to each model's own execution style kept both
integrations simple.

For inspecting a single run by hand, `--debug-flags=FaultTrace` dumps the
target register's value immediately before and after the flip. That's useful
for sanity-checking the injector itself, but it doesn't scale to answering
the actual research question, which needs hundreds or thousands of runs
across many (register, bit, cycle) combinations.

## Golden run first, then sample — not exhaustive sweep

Exhaustively testing every combination of register, bit position, and cycle
for a program running millions of cycles isn't feasible. `run_campaign.py`
takes a more practical approach: do one **golden run** with no fault to learn
how many cycles the program actually takes, split that duration into
intervals, and then run randomized (register, bit, cycle) samples per
interval. It's resumable and parallelizable across workers, so a campaign
can be stopped, restarted, or split across machines without losing progress
— which matters a lot once a sweep is large enough to take hours.

Each run outputs a small `fi_meta.txt` recording exactly what was injected
and what happened — for example, a flip at bit 31 of register 4, injected at
cycle 114963 of a 148408-cycle interval, completing in 0.6 seconds with
status `SUCCESS`. "Success" here just means the program ran to completion
despite the flip; it says nothing about whether the output was actually
correct, which is exactly the kind of silent-corruption case this whole
project exists to surface.

## What the sweep across SPEC CPU2017 shows

The larger campaign ran across eight SPEC CPU2017 benchmarks (qsort, sieve,
matmul, xalancbmk, radix, merge, LUDecomp, specrand) on both CPU models, and
classified every outcome as a crash, a silent corruption, or no visible
effect.

![Combined outcome summary across SPEC benchmarks](/assets/img/projects/gem5-fault-injection/combined-outcome-summary.png)
_Outcome classification aggregated across all SPEC benchmarks._

![Fault outcome heatmap by bit position and cycle](/assets/img/projects/gem5-fault-injection/spec-heatmap.png)
_Where in a program's execution — and which bit positions — faults are most likely to be consequential._

The scatter of every injected fault by bit position and cycle, colored by
outcome, is the artifact I keep coming back to: there's visible clustering,
meaning some phases of execution are much more fault-sensitive than others,
rather than fault sensitivity being roughly uniform across a program's
runtime.

![Bit position vs. injection cycle scatter, colored by outcome](/assets/img/projects/gem5-fault-injection/bit-cycle-scatter.png)
_Every injected fault plotted by bit position and cycle, colored by outcome._

That clustering is the kind of result that's hard to get any other way —
you'd need an enormous number of real-world fault observations to see the
same pattern, versus a controllable simulator where you can just ask for it
directly.

Full technical details, plus the smaller `towers5` demo sweep used as a
sanity check against the full SPEC results, are on the
[project page](/blog-site/projects/gem5-fault-injection/); the code is on
[GitHub](https://github.com/imndllnuri/riscv-gem5-fault-injector).
