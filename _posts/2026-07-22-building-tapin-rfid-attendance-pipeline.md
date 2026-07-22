---
title: "Building TapIn: an RFID Attendance Pipeline"
date: 2026-07-22 13:00:00 +0300
categories: [Course Project]
tags: [Embedded Systems, IoT]
---

Taking attendance by hand doesn't scale past a handful of students, and
paper or spreadsheet tracking is easy to falsify or lose. An RFID card tap
is fast, hard to fake on someone else's behalf, and works with student ID
cards people already carry — that was the premise behind TapIn, a 4-person
team project at Abdullah Gül University (COMP413). The original design was
a full IoT pipeline: RC522 RFID reader → ESP8266 NodeMCU over WiFi → Flask
REST API → MySQL on a Google Cloud `f1-micro` instance → a PyQt5 desktop GUI
with pie-chart attendance breakdowns and Excel export, plus an RGB LED at
the reader itself giving instant feedback (blue = ready, yellow =
processing, green = granted, red = denied). The team's IEEE-style paper
covers that full architecture in detail.

## What's still runnable is not what was originally built

This is the part I think is worth writing about, because it's usually
invisible in student hardware projects: the cloud infrastructure and the
ESP8266 hardware aren't available anymore, so what's in the public repo
today is deliberately the *buildable subset* of the original design, not
the whole thing pretending nothing changed.

Concretely: Flask + **SQLite** stands in for Flask + MySQL-on-Cloud, and
RFID capture over **direct serial** stands in for the ESP8266's WiFi/HTTP
link. The PyQt5 GUI and the Flask REST API layer are otherwise unchanged
from the original design — the substitution is scoped to exactly the two
pieces that depended on infrastructure and hardware that no longer exists.

![AttendU dashboard redesign showing class list and attendance percentages](/assets/img/projects/student-attendance-app/dashboard-redesign.png)
_Dashboard view from a later UI redesign exploration — pinned/active classes with live attendance rates, all placeholder data, no real student information._

## The seam that made the substitution painless

What makes this more than a one-off hack is that the abstraction it relies
on was built in from day one, not retrofitted after the hardware became
unavailable. `shared/hardware_config.py` and `services/card_reader.py`
define a `CardReader` abstract base class with two implementations:
`SerialCardReader` (the one actually running today) and `ESP8266CardReader`
(a WiFi/TCP implementation that's stubbed and still covered by
`tests/test_take_attendance_esp8266_backend.py`, even though it isn't the
live default).

The reasoning behind keeping that abstraction even when only one
implementation is in active use: the hardware substitution was known from
day one to be temporary, not a permanent architectural decision. With the
ABC in place, the rest of the app — the Flask API, the PyQt5 GUI, the
database layer — never needed to know or care which transport was
underneath. Restoring the original wireless design later means implementing
one class against an already-existing interface, not restructuring the
app around it.

![AttendU classes list with per-class attendance breakdown](/assets/img/projects/student-attendance-app/classes-redesign.png)
_Per-class attendance breakdown — sessions attended, missed, and archived._

## Why SQLite instead of trying to preserve the cloud database

Running a cloud MySQL instance costs money and requires ongoing
infrastructure upkeep that a course project — one meant to be clonable and
runnable by anyone, indefinitely, with no ops budget — can't justify.
SQLite is a drop-in relational database with zero setup, and Flask's
database access layer didn't need to change meaningfully to target it
instead. The substitution preserves the architecture the original paper
describes while making the repo genuinely self-contained: clone it, run it,
no cloud account required.

![AttendU sign-in screen](/assets/img/projects/student-attendance-app/login-redesign.png)
_Sign-in screen from the UI redesign exploration._

The bigger lesson, more than any specific technical choice here, is that a
project outliving its original infrastructure is normal, not a failure —
and an abstraction placed at the right seam (hardware transport, in this
case) is the difference between "the repo bit-rots the moment the cloud
instance gets torn down" and "the repo still builds, with one class ready
to swap back in if the original hardware ever comes back."

Full architecture write-up is on the
[project page](/blog-site/projects/student-attendance-app/); source is on
[GitHub](https://github.com/imndllnuri/students-attendance-app).
