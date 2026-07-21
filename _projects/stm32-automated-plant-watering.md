---
title: STM32 Automated Plant Watering
summary: An embedded automated plant-watering system on an STM32F103C that reads soil-moisture and water-level sensors and drives a pump when soil moisture drops below a threshold.
tech: [C, STM32 HAL, STM32CubeMX, Proteus]
type: Personal Project
highlight: Fully automated closed-loop watering driven by live sensor data
repo: https://github.com/imndllnuri/stm32-automated-plant-watering
demo:
order: 4
---

## Overview

A functional hardware prototype built around an STM32F103C (Cortex-M3)
microcontroller. Soil-moisture and water-level sensors are read via ADC/DMA,
readings are shown live on an LCD, and a pump/relay is driven automatically
once soil moisture drops below a threshold.

## Highlights

- STM32CubeMX-generated HAL code, hand-written control logic on top
- Circuit designed and validated in Proteus before hardware bring-up

## Links

- [Source code]({{ page.repo }})
