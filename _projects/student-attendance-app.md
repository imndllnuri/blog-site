---
title: "TapIn — Student Attendance App"
summary: A desktop + server app for instructors to manage classes and record student attendance via RFID, built as a course project at Abdullah Gül University.
tech: [Python, PyQt5, Flask, SQLite, pandas]
type: Course Project
highlight: RFID-based attendance capture on a PyQt5 + Flask stack
repo: https://github.com/imndllnuri/students-attendance-app
demo:
order: 5
---

## Overview

Originally an IoT pipeline (RFID + ESP8266 + Flask/MySQL + PyQt5) built for
a COMP413 course; this repo is the buildable subset using a local Flask +
SQLite server in place of the cloud/ESP8266 pieces. Provides account/class
management, RFID-based attendance capture over serial, and attendance
statistics with charts.

## Highlights

- PyQt5 desktop client talking to a Flask REST API backend
- RFID attendance capture over a serial connection
- Attendance stats and charts via pandas/matplotlib

## Links

- [Source code]({{ page.repo }})
