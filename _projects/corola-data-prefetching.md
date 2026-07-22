---
title: Corola Data Prefetching
summary: A BSc internship project on hardware data prefetching, simulating a custom high-coverage variant of the ip_stride prefetcher against the default using ChampSim traces.
tech: [C++, Python, Bash, ChampSim, Pin/SDE]
type: Internship
category: Internship
tags: [Computer Architecture, Research, Internship]
highlight: Custom prefetcher variant benchmarked against ChampSim's default
repo: https://github.com/imndllnuri/corola-data-prefetching
demo:
order: 3
---

## Overview

A BSc internship project (CoRoLa) evaluating a custom high-coverage variant
of the `ip_stride` hardware data prefetcher — `ip_stride_hc` — against
ChampSim's stock implementation. Built on top of CMU-SAFARI's Load-Inspector
tool and ChampSim, using Intel Pin/SDE to instrument the HPCG benchmark and
extract representative execution regions to simulate.

## Motivation

Modern CPUs spend a lot of their time stalled waiting for data to arrive
from memory. A hardware prefetcher tries to predict which memory addresses
the program is about to access and fetch them into cache *before* they're
needed, so the CPU doesn't stall. `ip_stride` — one of the standard
prefetchers implemented in the ChampSim simulator — predicts strided access
patterns per instruction pointer, but leaves coverage on the table in
workloads with more irregular or partially-strided access patterns, like
HPCG (a sparse linear-algebra benchmark). The internship's goal was to
extend `ip_stride` to catch more of those cases, and measure whether the
extra coverage was actually worth its cost.

## Architecture / how it works

The full pipeline, wrapped in a single `run.sh` with `setup`, `scaffold`,
`champsim-build`, `regions`, `traces`, and `simulate` stages:

1. **Instrumentation**: a magic-instruction patch (`magic-instruction.patch`)
   is applied to HPCG's `src/main.cpp`, inserting markers around the code
   regions worth tracing.
2. **Region/trace extraction**: Intel Pin/SDE runs the instrumented HPCG
   binary and, using CMU-SAFARI's Load-Inspector, extracts ChampSim-format
   memory traces for each marked region.
3. **Simulation**: `bsc-champsim/` (a ChampSim build, managed via vcpkg) runs
   each trace twice — once with the baseline `ip_stride` prefetcher, once
   with `ip_stride_hc` — toggled via a single flag,
   `USE_HC_VADDR_POLICY` in `bsc-champsim/inc/prefetch_config.h`, and the
   `"prefetcher"` field in `champsim_config.json`.
4. **Analysis**: `parser/all_runs.csv` collects IPC and cache-miss stats
   from every run; `parser/figure2.py`/`figure3.py`/`figure4.py` regex the
   raw ChampSim stdout into the plots below.

## Key design decisions

**Why HPCG specifically?** HPCG is a sparse-matrix/conjugate-gradient
benchmark — its memory access pattern is *mostly* strided but with enough
irregularity that a naive stride prefetcher misses real opportunities,
making it a good stress test for a prefetcher extension whose whole point is
catching cases the baseline doesn't.

**Why a single config-flag toggle instead of two separate prefetcher
implementations wired in permanently?** Keeping `ip_stride_hc` behind
`USE_HC_VADDR_POLICY` in the same codebase as the baseline makes an
apples-to-apples comparison a one-line config change rather than maintaining
two divergent ChampSim forks — every other simulation parameter (cache
sizes, core config, trace) stays identical between the baseline and
high-coverage runs, isolating the prefetcher as the only variable.

## Results

The core result: `ip_stride_hc` measurably improves both raw performance
and prefetch accuracy across every HPCG problem size tested, with the
biggest gains at the smallest problem size:

![Performance speedup and L1D prefetch accuracy, baseline vs. CoRoLa](/assets/img/projects/corola-data-prefetching/ipc-normalized-cache-misses.png)
_IPC speedup (left) and L1D prefetch accuracy (right) for `ip_stride_hc` vs. baseline `ip_stride`, across HPCG problem sizes 16–40 and four execution regions each._

At HPCG size 16, IPC speedup ranges from **+61% to +107%** depending on
region (region 0: 0.665→1.068 IPC; region 2: 0.657→1.36 IPC), tapering to a
still-solid **+20–22%** at HPCG sizes 24–40. L1D prefetch accuracy jumps from
roughly 35–48% (baseline) to consistently **96–98%** with `ip_stride_hc`
across every configuration.

![Normalized cache miss rate reduction by cache level](/assets/img/projects/corola-data-prefetching/ipc-comparison.png)
_Cache miss reduction at L1D, L2, and LLC — misses drop by 70-80% at most problem sizes, and by as much as ~66% (LLC) even at the smallest, HPCG-16._

**The honest tradeoff**: higher prefetch coverage isn't free. The more
aggressive `ip_stride_hc` also issues more speculative memory requests,
which shows up as increased STLB (second-level TLB) misses and DRAM
contention:

![STLB miss rate and DRAM contention analysis](/assets/img/projects/corola-data-prefetching/tlb-dram-analysis.png)
_Normalized STLB misses (left) reach up to ~209% of baseline at HPCG-24, and average DRAM-congested cycles (right) increase by roughly 20-47% across regions — the classic "more aggressive prefetching helps IPC but costs memory-system overhead" tradeoff._

This is a realistic result, not just a clean win: `ip_stride_hc` is a net
positive on IPC and accuracy for HPCG, but a production deployment decision
would need to weigh that against the extra memory-system pressure it
introduces — which is exactly the kind of tradeoff hardware prefetcher
research exists to quantify.

## Links

- [Source code]({{ page.repo }})
