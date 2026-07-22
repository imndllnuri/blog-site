---
title: DigiGarden Mobile App
summary: A React Native/Expo mobile app for Turkish farmers to manage fields, track soil health, and get data-driven fertilization recommendations from connected hardware sensors.
tech: [React Native, Expo, Firebase, Cloud Run]
type: Internship
category: Internship
tags: [Mobile Development, Internship]
highlight: Photo-based ML soil analysis integrated into a production app
repo:
demo:
order: 6
---

## Overview

Built during a software engineering internship at DigiGarden — "precision
soil intelligence for Turkish farmers." The app integrates with two pieces
of proprietary hardware, **DigiSoil** (soil texture analysis) and
**DigiFert** (NPK/nutrient analysis), plus live weather and news feeds, all
backed by Firebase (Auth, Firestore, Storage, Cloud Functions).

![DigiGarden home dashboard](/assets/img/projects/digigarden-mobile-app/homedashboard.jpg)
_The app's home dashboard — field overview and quick actions._

![A field view in the DigiGarden app](/assets/img/projects/digigarden-mobile-app/field.jpg)
_Field-level view, where soil/fertilization data gets tied to a specific plot of land._

<div class="row row-cols-2 g-2 mb-3">
  <div class="col text-center">
    <img src="/assets/img/projects/digigarden-mobile-app/digisoil-logo.png" alt="DigiSoil hardware logo" class="img-fluid">
    <p class="text-muted"><small>DigiSoil — soil texture sensor</small></p>
  </div>
  <div class="col text-center">
    <img src="/assets/img/projects/digigarden-mobile-app/digifert-logo.png" alt="DigiFert hardware logo" class="img-fluid">
    <p class="text-muted"><small>DigiFert — NPK/nutrient sensor</small></p>
  </div>
</div>

<!-- TODO: repo is private under the company's org, so no link is included
     here. Add one if you get permission to share it. -->

## Motivation

Fertilization decisions on a farm are usually made from experience and
visual inspection rather than measured soil data, which leaves real yield
and cost efficiency on the table. DigiGarden's premise is to put actual soil
composition and nutrient measurements — from purpose-built hardware — into
farmers' hands through a phone app, turning "I think this field needs more
nitrogen" into a specific, data-backed recommendation.

## Architecture / how it works

Expo Router drives navigation; React Context providers (Auth, Field,
Settings, Translation) hold app-wide state; a services layer talks to
Firebase (Auth, Firestore, Storage, and Cloud Functions — including
`onSampleWrittenJobAndPredict`, which reacts to a new sample being written
by kicking off a prediction job, and a monthly `checkInactiveFields` cron)
and to external APIs (Open-Meteo for weather, GNews for agriculture news,
plus a couple of small utility APIs). The stack is React Native 0.81.5 on
Expo SDK 54 with Expo Router 6 and Firebase 12, in plain JS/JSX.

Not every feature is wired to live hardware yet — the codebase tracks this
explicitly with a Live/Mocked/Placeholder status per feature. For example,
an NH₄ (ammonium) photo test is fully live end-to-end, while the DigiSoil
and DigiFert hardware scans are currently mocked pending the physical
devices and their computer-vision backend — a realistic snapshot of a
hardware-integrated product built in parallel with the hardware itself.

## Key design decisions

**Why Expo instead of bare React Native?** Expo's managed tooling (EAS
builds, over-the-air updates, a large first-party module ecosystem)
substantially cuts native-build maintenance overhead for a small team —
though this app pushes past what Expo Go (the sandboxed preview app) can
run, for reasons covered below.

**Why Firebase instead of a custom backend?** Firestore + Cloud Functions
gave the team a realtime database, auth, file storage, and serverless
compute without standing up and operating separate infrastructure for each
— appropriate for an internship-timescale MVP where engineering time is
better spent on the farming-specific logic (soil/fertilization models) than
on backend plumbing.

## Challenges & lessons learned

**Expo Go fundamentally can't run this app.** Expo Go — the QR-code-scan
preview app most Expo projects use for fast iteration — only supports a
fixed set of native modules. This app needs several packages that fall
outside that set: `react-native-vision-camera` and
`react-native-document-scanner-plugin` (for the photo-based soil/nutrient
capture flows), `react-native-nitro-modules`, Google Sign-In, and worklets.
Every one of those requires a custom native build (an Expo "dev client")
instead of Expo Go — a real workflow cost that only becomes visible once a
project's feature set outgrows what the sandboxed preview app supports, and
a good concrete example of why "just use Expo Go" isn't always the right
default assumption for a React Native project.

## Links

_Source is private under the company's GitHub org — no public link available._
