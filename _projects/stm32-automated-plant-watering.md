---
title: STM32 Automated Plant Watering
summary: An embedded automated plant-watering system on an STM32F103C that reads soil-moisture and water-level sensors and drives a pump when soil moisture drops below a threshold.
tech: [C, STM32 HAL, STM32CubeMX, Proteus]
type: Personal Project
category: Personal Project
tags: [Embedded Systems]
highlight: Fully automated closed-loop watering driven by live sensor data
repo: https://github.com/imndllnuri/stm32-automated-plant-watering
demo:
order: 4
---

## Overview

A functional hardware prototype built around an STM32F103C (Cortex-M3)
microcontroller. Soil-moisture and water-level sensors are read via ADC/DMA,
readings are shown live on a character LCD, and a pump/relay is driven
automatically once soil moisture drops below a threshold — a small,
self-contained closed-loop control system.

## Motivation

Watering a plant reliably is a genuinely simple control problem — read a
sensor, compare it to a threshold, actuate a pump — which made it a good
target for practicing the *full* embedded workflow end to end: circuit
design, HAL configuration, control logic, and simulation-before-hardware
validation, rather than just wiring a sensor to a dev board and calling it
done.

## Architecture / how it works

![Proteus circuit simulation showing live sensor readings on the LCD](/assets/img/projects/stm32-automated-plant-watering/proteus-simulation.png)
_The full circuit running in Proteus: STM32F103C6, soil moisture probe, water-level sensor, and character LCD showing live readings (`Soil: 3979`, `Water: 459`) before any hardware was touched._

The control loop is straightforward but the implementation detail is in the
HAL configuration:

- **`ADC_CHANNEL_8`** reads the soil-moisture probe, **`ADC_CHANNEL_9`**
  reads the water-level sensor, both configured via
  `HAL_ADC_ConfigChannel`.
- **DMA-driven conversion**: rather than blocking on
  `HAL_ADC_PollForConversion` for every reading, `MX_DMA_Init()` sets up
  `DMA1_Channel1` so ADC conversions complete in the background while the
  main loop keeps servicing the LCD and pump logic.
- The main loop (`ReadSensors()` → `UpdateLCD()`) continuously refreshes
  both readings, and a threshold check on soil moisture toggles the pump
  relay's GPIO pin.

## Key design decisions

**Why DMA instead of polling the ADC directly?** A single-threaded
`while(1)` loop that blocks on `HAL_ADC_PollForConversion` ties up the CPU
for the whole conversion, which is wasteful when the same loop also needs to
keep the LCD responsive and re-check the pump threshold promptly. Letting
DMA move completed ADC samples into memory in the background keeps the main
loop free to do everything else without missing a threshold crossing.

**Why validate in Proteus before touching real hardware?** Simulating the
full circuit first — including watching the LCD update with plausible sensor
values as shown above — caught wiring and logic issues (pin mappings,
threshold logic) in software, where a mistake costs a re-simulation instead
of a re-soldering. Proteus's ability to animate the exact STM32CubeMX-
generated firmware against a simulated circuit made "hardware bring-up" the
last step instead of the first debugging step.

**Why STM32CubeMX-generated HAL instead of bare-metal register access?**
CubeMX generates correct, portable peripheral initialization (clock trees,
GPIO/ADC/DMA setup) that would otherwise be tedious and error-prone to hand
write for an F1-series part, letting the actual project-specific work — the
sensor-read/threshold/actuate control logic — be layered cleanly on top
instead of buried in boilerplate.

## Links

- [Source code]({{ page.repo }})
