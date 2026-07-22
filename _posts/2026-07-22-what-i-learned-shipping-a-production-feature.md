---
title: "What I Learned Shipping a Production Feature During an Internship"
date: 2026-07-22 14:00:00 +0300
categories: [Internship]
tags: [Mobile Development, Internship]
---

I spent my software engineering internship at DigiGarden — "precision soil
intelligence for Turkish farmers" — working on the React Native/Expo app
that connects two pieces of proprietary hardware, DigiSoil (soil texture
analysis) and DigiFert (NPK/nutrient analysis), to farmers' phones. The
repo is private under the company's org, so this isn't a code walkthrough —
it's the lessons that were actually worth carrying forward, told without
needing the internals.

![DigiGarden home dashboard](/assets/img/projects/digigarden-mobile-app/homedashboard.jpg)
_The app's home dashboard — field overview and quick actions._

## The product problem was more interesting than it sounds

Fertilization decisions on a farm are usually made from experience and
visual inspection, not measured data — which leaves real yield and cost
efficiency on the table. DigiGarden's whole premise is turning "I think
this field needs more nitrogen" into a specific, data-backed recommendation
by putting actual soil composition and nutrient measurements into a phone
app. That's a genuinely different kind of problem than most mobile apps
solve: the UI isn't the product, it's the delivery mechanism for hardware
measurements and a prediction pipeline behind them.

## Building against hardware that doesn't fully exist yet

The most useful thing I learned wasn't about React Native at all — it was
about how to build a hardware-integrated product *in parallel* with the
hardware itself, without either side blocking the other. The codebase
tracks feature status explicitly as Live, Mocked, or Placeholder. An NH₄
(ammonium) photo test, for instance, was fully live end-to-end — camera
capture, backend processing, real results. The DigiSoil and DigiFert
hardware scans, on the other hand, were mocked, because the physical
devices and their computer-vision backend weren't ready yet.

That's not a workaround to be embarrassed about — it's how you keep a team
shipping when hardware and software are on different timelines. The
alternative (blocking all UI work until hardware is finalized) wastes the
software team's time; building against a fixed mock interface that later
gets swapped for the real integration point keeps everyone moving without
anyone building against a moving target they can't predict.

![A field view in the DigiGarden app](/assets/img/projects/digigarden-mobile-app/field.jpg)
_Field-level view, where soil and fertilization data get tied to a specific plot of land._

## The tooling assumption that turned out to be wrong

Going in, I assumed Expo Go — the QR-code-scan preview app most Expo
projects use for fast iteration — would be enough for day-to-day
development. It wasn't, and the reason is worth remembering for any future
React Native project: Expo Go only supports a fixed set of native modules,
and this app needed several that fall outside it —
`react-native-vision-camera` and `react-native-document-scanner-plugin`
(for the photo-based soil/nutrient capture flows), Google Sign-In, worklets,
and a couple of others. Every one of those requires a custom native build
(an Expo "dev client") instead of Expo Go.

That's a real workflow cost, and it only becomes visible once a project's
feature set outgrows what the sandboxed preview app supports — which is
exactly the trap: "just use Expo Go" is the default advice for a reason, it
works for most projects, right up until a camera/document-scanning-heavy
feature set silently pushes you past it. The lesson generalizes past Expo
specifically: know which parts of your toolchain quietly assume a
constrained feature set, before you're deep enough into a project that
switching costs real time.

## What actually mattered

None of the above is about a clever algorithm or a hard technical problem —
it's about the unglamorous parts of shipping something real: working
against hardware that isn't finished, being honest in the codebase about
what's actually live versus mocked, and noticing early when your dev
tooling stops matching your project's actual requirements. Those are the
skills that don't show up in a tutorial, and they were the actual value of
the internship.

More detail (architecture, tech stack) is on the
[project page](/blog-site/projects/digigarden-mobile-app/) — the source
itself is private under the company's GitHub org, so there's no public
repo link to share.
