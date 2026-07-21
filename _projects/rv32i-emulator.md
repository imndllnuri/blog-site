---
title: RV32I Emulator
summary: A Linux-native RISC-V (RV32I + RV32M) emulator with a Qt GUI, built to learn CPU emulation and ISA design, inspired by the Windows-only Easy68k debugger.
tech: [C++, Python, PyQt5, pybind11, CMake]
repo: https://github.com/imndllnuri/rv32i-emulator
demo: https://github.com/imndllnuri/rv32i-emulator/releases
order: 1
---

## Overview

A C++ CPU core (decode/execute, registers, memory) exposed to Python via
pybind11, paired with a PyQt5 GUI for syntax-highlighted assembly editing and
live register/memory/stack/disassembly views with breakpoint support.

## Highlights

- Full RV32I + RV32M instruction support with a from-scratch CPU core
- GUI debugger modeled after Easy68k, but cross-platform
- Packaged as a Linux AppImage via PyInstaller for easy distribution

## Links

- [Source code]({{ page.repo }})
- [Releases]({{ page.demo }})
