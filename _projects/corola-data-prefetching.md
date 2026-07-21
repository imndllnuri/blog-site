---
title: Corola Data Prefetching
summary: A BSc internship project on hardware data prefetching, simulating a custom high-coverage variant of the ip_stride prefetcher against the default using ChampSim traces.
tech: [C++, Python, Bash, ChampSim, Pin/SDE]
type: Internship
highlight: Custom prefetcher variant benchmarked against ChampSim's default
repo: https://github.com/imndllnuri/corola-data-prefetching
demo:
order: 3
---

## Overview

Instruments the HPCG benchmark with Intel Pin/SDE to extract execution
regions, generates ChampSim traces from them, and evaluates a custom
high-coverage `ip_stride_hc` prefetcher variant against ChampSim's default
`ip_stride` prefetcher.

## Highlights

- End-to-end pipeline: instrumentation → trace generation → simulation →
  results, wrapped in a single `run.sh` pipeline
- Builds on CMU-SAFARI's Load-Inspector and ChampSim research tooling

## Links

- [Source code]({{ page.repo }})
