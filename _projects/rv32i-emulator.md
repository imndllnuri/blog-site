---
title: RV32I Emulator
summary: A Linux-native RISC-V (RV32I + RV32M) emulator with a Qt GUI, built to learn CPU emulation and ISA design, inspired by the Windows-only Easy68k debugger.
tech: [C++, Python, PyQt5, pybind11, CMake]
type: Personal Project
category: Personal Project
tags: [Computer Architecture]
highlight: Full RV32I + RV32M ISA implemented with a GUI debugger
repo: https://github.com/imndllnuri/rv32i-emulator
demo: https://github.com/imndllnuri/rv32i-emulator/releases
order: 1
---

## Overview

A C++ CPU core — fetch, decode, execute, registers, memory — exposed to
Python via pybind11, paired with a PyQt5 GUI for syntax-highlighted assembly
editing and live register/memory/stack/disassembly views with breakpoint
support. It implements the full RV32I base integer ISA plus the RV32M
multiply/divide extension, and ships as a self-contained Linux AppImage.

![RV32I emulator GUI with a Fibonacci program loaded, before running](/assets/img/projects/rv32i-emulator/gui-loaded.png)
_The editor with a hand-written RV32I program loaded (iteratively computing `fib(10)`), and the Registers panel showing the CPU's reset state — `sp` initialized to the top of memory, everything else zeroed._

## Motivation

I'd previously used Easy68k to learn 68k assembly, and liked how directly it
let you watch a CPU execute instruction-by-instruction — registers updating,
flags flipping, memory changing in real time. The catch: Easy68k is
Windows-only and tied to an instruction set nobody actually ships silicon for
anymore. RISC-V, by contrast, is an ISA I could plausibly touch in the real
world (from a Raspberry Pi RISC-V board to research cores), and building the
CPU core myself — rather than just using an existing emulator — was the
actual point: I wanted to *understand* instruction decode and execution well
enough to implement it, not just read about it.

## Architecture

The project splits cleanly into three layers (see `docs/ARCHITECTURE.md` in
the repo for the full file-by-file breakdown):

- **`core/`** — the CPU itself, in C++: `include/{cpu,csr,decode,execute,
  fetch,instruction,memory,register}.hpp` implement a classic
  fetch–decode–execute loop over a flat memory model, plus a CSR
  (control/status register) file for the machine-mode state RV32I programs
  expect to exist. `core/src/pycpu.cpp` is the pybind11 binding layer that
  exposes this C++ core as an importable Python module.
- **`gui/`** — a PyQt5 application: a syntax-highlighted assembly editor,
  and dockable/tabbed views for registers, memory, the stack, and live
  disassembly, plus breakpoints, step-over/step-out, and PC history for
  stepping backward through execution.
- **`assembler/`** — 14 example RV32I/RV32M programs (fibonacci, factorial,
  gcd, bubble sort, and others) used both as smoke tests and as a way to
  exercise every instruction category the core implements.

The Disassembly and Memory views make the fetch/decode step and the
assembled binary's actual byte layout directly inspectable, not just the
source assembly:

<div class="row row-cols-1 row-cols-md-2 g-2 mb-3">
  <div class="col">
    <img src="/assets/img/projects/rv32i-emulator/gui-disassembly.png" alt="Disassembly view decoding each instruction back from machine code" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Disassembly: each address, raw instruction bytes, and the decoded mnemonic</small></p>
  </div>
  <div class="col">
    <img src="/assets/img/projects/rv32i-emulator/gui-memory.png" alt="Memory hex dump view" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Memory: a live hex/ASCII dump, following the program counter</small></p>
  </div>
</div>

## Key design decisions

**Why expose the core to Python instead of writing the whole thing in C++
(or the whole thing in Python)?** A pure-Python CPU core would make every
single-step slow enough to be annoying in a GUI debugger; a pure-C++ GUI
would mean fighting Qt's C++ API and a slower edit-compile-run loop for what
is fundamentally UI work. pybind11 let the performance-sensitive part (the
actual instruction execution) stay in C++ while the GUI — which changes far
more often during development than the ISA does — stays in fast-iterating
Python/PyQt5.

**Why model the debugger after Easy68k specifically?** Because that
particular interaction model — edit assembly, assemble, single-step, watch
every register and memory cell update live — was what made 68k assembly
click for me originally. Rather than inventing a new debugging UX from
scratch, I copied the parts of that experience that worked (dockable
register/memory/stack views, step-over/step-out, breakpoints) and made it
cross-platform.

**Why package as an AppImage?** The GUI depends on PyQt5, and asking anyone
who wants to try the emulator to first set up a matching Python + Qt
environment is enough friction that most people won't bother. An AppImage
(built via PyInstaller) bundles the interpreter and Qt libraries into one
executable file — download, `chmod +x`, run.

## Results

Running the loaded program to completion is the real proof the core
correctly implements the ISA rather than just parsing it — arithmetic,
branches, and register writes all have to behave exactly as RISC-V specifies
for the final register state to come out right:

![Registers panel after execution halts, showing t4 holding the computed Fibonacci result](/assets/img/projects/rv32i-emulator/gui-result.png)
_After the CPU halts, `t3` (the loop counter) holds `10` and `t4` holds `0x37` — 55 in decimal — exactly matching `fib(10) = 55`, the value the assembly's own comment predicts._

## Challenges & lessons learned

The `CHANGELOG.md` doubles as an honest record of what didn't work the first
time. Two examples worth calling out:

- **CSR handling bug**: an early version of the CSR (control/status
  register) logic had a bug in the generated assembly around CSR
  instructions that wasn't caught until specific programs exercising
  machine-mode state hit it — a good reminder that "compiles and runs on the
  happy path" and "correctly implements the ISA spec" are different bars.
- **GUI layout churn**: the debugger originally had six independent floating
  dock panels (registers, memory, stack, disassembly, etc.), which looked
  flexible on paper but was disorienting in practice — closing/losing one
  panel, or dragging them into an unusable arrangement, was a constant
  annoyance. It was replaced with a single tabbed panel, which is a less
  "powerful" layout on paper but is what a debugger you actually want to use
  every day needs.

## Links

- [Source code]({{ page.repo }})
- [Releases]({{ page.demo }})
