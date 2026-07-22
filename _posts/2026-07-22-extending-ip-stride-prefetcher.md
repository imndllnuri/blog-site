---
title: "Extending ChampSim's ip_stride Prefetcher for Higher Coverage"
date: 2026-07-22 09:00:00 +0300
categories: [Internship]
tags: [Computer Architecture, Internship, Research]
---

During my CoRoLa internship I spent most of my time inside a single question:
can a well-known hardware prefetcher be pushed to cover more cases without
throwing away what makes it cheap? The prefetcher in question was
`ip_stride`, one of the reference prefetchers shipped with
[ChampSim](https://github.com/ChampSim/ChampSim), and the workload that
exposed its blind spots was HPCG — a sparse-matrix conjugate-gradient
benchmark whose memory access pattern is *mostly* strided, but not cleanly
enough for a naive per-instruction stride predictor to catch everything.

## Why HPCG breaks a plain stride predictor

`ip_stride` predicts the next address touched by a given instruction pointer
by watching how far apart consecutive accesses from that same instruction
have been. That works well when a loop strides through memory in fixed
jumps. HPCG mostly does that — it's sparse linear algebra, after all — but
"mostly" is the operative word. Enough of its access pattern deviates from a
clean stride that a chunk of genuinely predictable memory traffic slips
through uncovered. That gap was the whole reason the internship existed:
if there's structure being missed, is it structure a slightly smarter
version of the same prefetcher can pick up cheaply, or does it need a
completely different prefetching strategy?

## Keeping the comparison honest

The easiest way to get a meaningless result here is to build two divergent
prefetchers and compare them under slightly different conditions. So instead
of forking ChampSim, the high-coverage variant — `ip_stride_hc` — lives in
the *same* codebase as the baseline, gated behind one compile-time flag
(`USE_HC_VADDR_POLICY` in `bsc-champsim/inc/prefetch_config.h`) and one
config field (`champsim_config.json`'s `"prefetcher"` key). Every other
simulation parameter — cache sizes, core config, the trace itself — stays
byte-for-byte identical between a baseline run and an `_hc` run. The
prefetcher is the only variable that moves.

Getting real traces to feed ChampSim meant instrumenting HPCG itself: a
small patch inserts marker instructions around the code regions worth
tracing, Intel Pin/SDE runs the instrumented binary, and CMU-SAFARI's
Load-Inspector turns that into ChampSim-format memory traces. The whole
pipeline — instrument, extract regions, trace, simulate, parse — is wrapped
in one `run.sh` with discrete stages, which made it possible to re-run just
the "simulate" step over and over while tuning `ip_stride_hc` without
re-instrumenting HPCG each time.

## What the extra coverage actually buys you

The headline result held up across every HPCG problem size tested:
`ip_stride_hc` improves both raw IPC and prefetch accuracy, with the
largest gains at the smallest problem size.

![Performance speedup and L1D prefetch accuracy, baseline vs. CoRoLa](/assets/img/projects/corola-data-prefetching/ipc-normalized-cache-misses.png)
_IPC speedup (left) and L1D prefetch accuracy (right) for `ip_stride_hc` vs. baseline `ip_stride`, across HPCG problem sizes 16–40._

At HPCG size 16, IPC speedup ranged from **+61% to +107%** depending on the
execution region, tapering to a still-solid **+20–22%** at sizes 24–40. L1D
prefetch accuracy jumped from roughly 35–48% under the baseline to a
consistent **96–98%** with the high-coverage variant — the kind of gap that
suggests the baseline really was leaving predictable accesses on the table,
not that the workload was simply hard to prefetch.

But more coverage isn't free. `ip_stride_hc` issues more speculative memory
requests, and that shows up downstream as increased second-level TLB misses
and DRAM contention — STLB misses reached roughly 209% of baseline at HPCG
size 24, and average DRAM-congested cycles rose 20–47% across regions. It's
the textbook aggressive-prefetching tradeoff, and the honest conclusion is
that `ip_stride_hc` is a net win for HPCG on IPC and accuracy, but a real
deployment decision would have to weigh that against the extra pressure it
puts on the memory system.

The full write-up, including the miss-rate breakdown by cache level and the
complete pipeline details, is on the
[project page](/blog-site/projects/corola-data-prefetching/); the code is on
[GitHub](https://github.com/imndllnuri/corola-data-prefetching).
