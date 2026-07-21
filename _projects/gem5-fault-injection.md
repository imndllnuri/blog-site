---
title: gem5 Fault Injection
summary: A fork of the gem5 architecture simulator adding a deterministic single-bit register fault injector for RISC-V, used to study CPU soft-error resiliency.
tech: [C++, Python, SCons, gem5]
repo: https://github.com/imndllnuri/riscv-gem5-fault-injector
demo:
order: 2
---

## Overview

Adds a `FaultInjector` SimObject to gem5's RISC-V `AtomicSimpleCPU`/
`TimingSimpleCPU` models that flips a single bit in a register at a precise
cycle, so the resulting crash / silent corruption / no-effect outcome can be
observed and classified.

## Highlights

- Deterministic, cycle-accurate fault injection into gem5's CPU models
- Campaign runner automating golden runs plus randomized parameter sweeps,
  with parallel and resumable execution across register/cycle combinations

## Links

- [Source code]({{ page.repo }})
