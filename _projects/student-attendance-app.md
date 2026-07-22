---
title: "TapIn — Student Attendance App"
summary: A desktop + server app for instructors to manage classes and record student attendance via RFID, built as a course project at Abdullah Gül University.
tech: [Python, PyQt5, Flask, SQLite, pandas]
type: Course Project
category: Course Project
tags: [Embedded Systems, IoT]
highlight: RFID-based attendance capture on a PyQt5 + Flask stack
repo: https://github.com/imndllnuri/students-attendance-app
demo:
order: 5
---

## Overview

Originally an IoT pipeline — RFID reader + ESP8266 NodeMCU + Flask/MySQL
backend + PyQt5 GUI — built as a 4-person team project (COMP413, Abdullah
Gül University); this repo is the buildable subset that stands on its own
without the original cloud infrastructure and hardware, using a local Flask
+ SQLite server and direct serial RFID capture in their place. Provides
account/class management, RFID-based attendance capture, and attendance
statistics with charts.

The UI shown below is a newer redesign exploration (mockups, not the
original screenshots), built with placeholder demo data — no real student
information appears anywhere in this write-up:

![AttendU dashboard redesign showing class list and attendance percentages](/assets/img/projects/student-attendance-app/dashboard-redesign.png)
_Dashboard view: pinned/active classes with live attendance rates, all data is placeholder._

![AttendU sign-in screen](/assets/img/projects/student-attendance-app/login-redesign.png)
_Sign-in screen from the UI redesign exploration._

![AttendU classes list with per-class attendance breakdown](/assets/img/projects/student-attendance-app/classes-redesign.png)
_Per-class attendance breakdown — sessions attended/missed/archived._

## Motivation

The original design targeted a real deployment problem: taking attendance by
hand doesn't scale past a handful of students, and paper/spreadsheet
tracking is easy to falsify or lose. An RFID card tap is fast, hard to fake
on someone else's behalf, and works with student ID cards students already
carry — the team's original IEEE-style paper on the design covers the full
RFID + ESP8266 + Google Cloud MySQL + PyQt5 architecture in detail.

## Architecture / how it works — the aspirational vs. the buildable

This project is unusually explicit about a gap that's common in student
hardware projects but rarely documented: the *original* design and what's
actually still runnable are not the same thing.

**Original design**: RC522 RFID reader → ESP8266 NodeMCU (WiFi) → Flask
REST API → MySQL on a Google Cloud `f1-micro` instance → PyQt5 desktop GUI
with QtChart pie charts and Excel export, plus an RGB LED giving instant
feedback at the reader itself (blue = ready, yellow = processing, green =
granted, red = denied).

**What ships in this repo today**: the ESP8266/MySQL/cloud pieces aren't
available anymore, so the repo is the subset that still builds and runs —
Flask + **SQLite** standing in for Flask + MySQL-on-Cloud, and RFID capture
over **direct serial** standing in for the ESP8266's WiFi/HTTP link. The
PyQt5 GUI and Flask REST API layer are otherwise unchanged from the original
design.

Critically, this isn't just documented as a future intention — the codebase
already has the seam built in: `shared/hardware_config.py` and
`services/card_reader.py` define a `CardReader` abstract base class with two
implementations, `SerialCardReader` (the one actually used today) and
`ESP8266CardReader` (a WiFi/TCP implementation, stubbed and covered by
`tests/test_take_attendance_esp8266_backend.py`, but not the live default).
Swapping the original ESP8266 hardware back in would mean implementing one
class against an existing interface, not restructuring the app.

## Key design decisions

**Why keep the `CardReader` abstraction even though only one implementation
is currently used?** Because the hardware substitution (serial ↔ ESP8266) was
known from day one to be temporary, not a permanent design choice — an ABC
with a `SerialCardReader` and a stubbed `ESP8266CardReader` means the rest of
the app (Flask API, PyQt5 GUI, database layer) never needed to know or care
which transport was underneath, and restoring the original wireless design
later is a contained change instead of a rewrite.

**Why Flask + SQLite instead of trying to keep Flask + MySQL-on-Cloud?**
Running a cloud MySQL instance costs money and requires ongoing
infrastructure upkeep neither justified for a course project meant to be
runnable by anyone who clones the repo. SQLite is a drop-in relational
database with zero setup, and Flask's database access layer doesn't need to
change meaningfully to target it instead — the substitution preserves the
architecture the paper describes while making the repo self-contained.

## Links

- [Source code]({{ page.repo }})
