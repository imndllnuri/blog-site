---
title: "Building a RISC-V Emulator from Scratch"
date: 2026-07-22 11:00:00 +0300
categories: [Personal Project]
tags: [Computer Architecture]
---

Before this project, my mental model of "how a CPU executes an instruction"
came from Easy68k — a 68k assembly IDE with a debugger that lets you watch
registers, flags, and memory update in real time as you single-step through
a program. It's what made assembly click for me. The problem is Easy68k is
Windows-only and built around an instruction set nobody ships silicon for
anymore. So the plan was: keep the part of that experience that actually
worked — step-by-step, everything-visible debugging — and rebuild it around
an ISA I could plausibly touch in the real world, RISC-V, while implementing
the CPU core myself instead of wrapping an existing emulator. Reading about
fetch/decode/execute isn't the same as being forced to get every encoding
bit right yourself.

![RV32I emulator GUI with a Fibonacci program loaded, before running](/assets/img/projects/rv32i-emulator/gui-loaded.png)
_The editor with a hand-written RV32I program loaded, and the Registers panel showing the CPU's reset state._

## Three layers, split by what changes fast

The project ended up in three pieces. `core/` is the CPU itself in C++ —
fetch, decode, execute, registers, memory, and a CSR (control/status
register) file for the machine-mode state RV32I programs expect to exist.
`gui/` is a PyQt5 app: a syntax-highlighted editor plus dockable views for
registers, memory, the stack, and live disassembly, with breakpoints and
step-over/step-out support. `assembler/` holds 14 example RV32I/RV32M
programs — fibonacci, factorial, gcd, bubble sort, and others — that double
as smoke tests exercising every instruction category the core implements.

The two layers meet through `core/src/pycpu.cpp`, a pybind11 binding that
exposes the C++ CPU as an importable Python module. That split wasn't
arbitrary: a pure-Python CPU core would make every single-step slow enough
to be annoying in a GUI debugger, and a pure-C++ GUI would mean fighting
Qt's C++ API for what is fundamentally UI work that changes far more often
during development than the ISA does. Keeping the hot path (instruction
execution) in C++ and the fast-iterating part (the GUI) in Python turned
out to be the right boundary.

## Making the machine code itself inspectable

Copying Easy68k's debugging UX meant more than just registers-updating-live
— it meant being able to see the assembled binary's actual byte layout, not
just trust that the assembler did the right thing.

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

The Disassembly view decodes machine code back into mnemonics independently
of the source — if the core's decode logic has a bug, this is where it
shows up first, since it's reading the same bytes the CPU itself fetches
and executes.

## Shipping it as something people would actually run

A Python + Qt dependency is enough setup friction that most people
evaluating a random GitHub project won't bother. So the emulator ships as a
self-contained Linux AppImage, built via PyInstaller, bundling the
interpreter and Qt libraries into one executable — download, `chmod +x`,
run, no environment to configure.

## Proof it's not just a fancy hex viewer

The real test of whether the core correctly *implements* the ISA, rather
than just parsing assembly text, is whether a real program produces the
right answer at the end:

![Registers panel after execution halts, showing t4 holding the computed Fibonacci result](/assets/img/projects/rv32i-emulator/gui-result.png)
_After the CPU halts, `t3` (the loop counter) holds `10` and `t4` holds `0x37` — 55 in decimal — exactly matching `fib(10) = 55`._

Arithmetic, branches, and register writes all had to behave exactly as the
RISC-V spec describes for that final register state to come out right — a
single off-by-one in decode or a wrong ALU op would have produced a
plausible-looking but incorrect number instead.

## Two things that didn't work the first time

The changelog is an honest record of the false starts, and two are worth
calling out. First, an early version of the CSR logic had a bug that only
showed up once a program actually exercised machine-mode state — a good
reminder that "compiles and runs on the happy path" and "correctly
implements the spec" are different bars, and RV32I gives you plenty of
surface area to pass the first without clearing the second.

Second, the debugger originally had six independent floating dock panels —
registers, memory, stack, disassembly, and more — which looked flexible on
paper but was disorienting in practice: panels got lost, dragged into
unusable arrangements, or closed by accident. It got replaced with a single
tabbed panel. Less "powerful" as a layout, but it's what a debugger you
actually want to open every day needs — the Easy68k lesson applied a second
time, this time about UI restraint rather than CPU semantics.

Full architecture notes and the file-by-file breakdown are on the
[project page](/blog-site/projects/rv32i-emulator/); source is on
[GitHub](https://github.com/imndllnuri/rv32i-emulator), and prebuilt
AppImage releases are [here](https://github.com/imndllnuri/rv32i-emulator/releases).
