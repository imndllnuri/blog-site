---
title: Easy Sort
summary: A lightweight Minecraft mod (Fabric + NeoForge) adding one-hotkey inventory/chest sorting, quick-stack, and restock, without the bloat of full inventory-management suites.
tech: [Java, Gradle, Fabric API, NeoForge]
type: Open Source
category: Open Source
tags: [Open Source]
highlight: Published on Modrinth & CurseForge, v1.4.1 and actively maintained
repo: https://github.com/imndllnuri/easy-sort
demo: https://modrinth.com/mod/easy-sort
order: 7
---

## Overview

A stable, actively maintained Minecraft mod (currently v1.4.1) that adds
one-hotkey sorting to any chest-type container — chests, double chests,
barrels, trapped chests, ender chests, minecarts, and shulker boxes — plus
Quick Stack and Restock, supporting both the Fabric and NeoForge mod loaders
across multiple Minecraft version branches.

<div class="row row-cols-1 row-cols-md-2 g-2 mb-3">
  <div class="col">
    <img src="/assets/img/projects/easy-sort/chest-before.png" alt="Chest before sorting" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Before</small></p>
  </div>
  <div class="col">
    <img src="/assets/img/projects/easy-sort/chest-after.png" alt="Chest after sorting" class="img-fluid rounded">
    <p class="text-muted text-center"><small>After one hotkey press</small></p>
  </div>
</div>

## Motivation

Minecraft's inventory and chest UI gives you no built-in way to organize
stacks — items pile up in whatever order you happened to pick them up.
Most existing sorting mods solve this by bundling an entire
inventory-management suite (custom storage systems, new UI overlays,
crafting changes) — more surface area than the actual problem needs. The
goal here was narrower and more personal: one hotkey, sorts the container
you're looking at, and otherwise gets out of the way. Building it was also
a deliberate way to learn Java and Minecraft's modding APIs from scratch, on
a project small enough to actually finish and ship.

## Architecture / how it works

The project is a multi-module Gradle build (via Architectury Loom) with
three modules — `common`, `fabric`, and `neoforge` — under one hard,
build-system-enforced rule: **`common/` may import zero Minecraft or
loader-specific classes.** All the actual sorting logic lives in `common/`
as plain Java operating on abstracted inventory data; `fabric/` and
`neoforge/` each provide only the thin per-loader glue (mixins, event
registration, networking) that wires that logic into their respective
mod-loading APIs.

Sorting is **server-authoritative**: pressing the hotkey sends a small
"sort this container" intent packet to the server, which re-validates the
request and performs the actual sort, then does a full menu resync back to
the client — rather than sorting client-side and hoping the server agrees.
This avoids the desync/duplication bugs that client-authoritative inventory
mods are prone to in multiplayer.

<div class="row row-cols-1 row-cols-md-2 g-2 mb-3">
  <div class="col">
    <img src="/assets/img/projects/easy-sort/shulker-box-before.png" alt="Shulker box before sorting" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Shulker box, before</small></p>
  </div>
  <div class="col">
    <img src="/assets/img/projects/easy-sort/shulker-box-after.png" alt="Shulker box after sorting" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Shulker box, after</small></p>
  </div>
</div>

Sort order itself is configurable — by mod origin or by item ID — via an
in-game settings screen:

<div class="row row-cols-1 row-cols-md-2 g-2 mb-3">
  <div class="col">
    <img src="/assets/img/projects/easy-sort/settings-sort-by-mod.png" alt="Settings: sort by mod" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Sort-by-mod setting</small></p>
  </div>
  <div class="col">
    <img src="/assets/img/projects/easy-sort/settings-sort-by-item-id.png" alt="Settings: sort by item ID" class="img-fluid rounded">
    <p class="text-muted text-center"><small>Sort-by-item-ID setting</small></p>
  </div>
</div>

## Key design decisions

**Why support both Fabric and NeoForge instead of picking one?** The
Minecraft modding community is split roughly along Fabric/NeoForge lines,
and a sorting mod is exactly the kind of small utility that players on
either loader want — the multi-loader Architectury setup means the
sorting logic is written once in `common/` and the loader-specific work is
just the thin adapter layer, not a second implementation.

**Why enforce "zero Minecraft imports in `common/`" at the build level
instead of just as a convention?** A convention gets violated the first
time it's inconvenient. Making the constraint a build-system rule means a
stray import that would silently couple the shared logic to one loader's
API gets caught immediately, rather than discovered later when the other
loader's build breaks or diverges.

**Why server-authoritative networking for something as simple as sorting a
chest?** Because "simple" client-side sorting mods are a classic source of
item duplication and desync bugs in multiplayer — the client and server
disagreeing about container contents even briefly is enough to duplicate or
lose items. Treating the client's hotkey press as a request rather than an
action, and letting the server own the actual mutation, closes that class
of bug entirely.

## Challenges & lessons learned

Publishing to Modrinth and CurseForge via CI, and maintaining support across
several actively-diverging Minecraft versions (with older branches frozen
rather than back-ported indefinitely) turned "write a mod" into "maintain a
small piece of infrastructure" — version-matrix support and a real release
process (`CHANGELOG.md`, `ROADMAP.md`) ended up being as much of the ongoing
work as the original sorting feature itself.

## Links

- [Source code]({{ page.repo }})
- [Modrinth]({{ page.demo }})
- [CurseForge](https://www.curseforge.com/minecraft/mc-mods/easy-sort)
