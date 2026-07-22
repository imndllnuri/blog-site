---
title: "Why I Built (and Kept Maintaining) a Minecraft Mod"
date: 2026-07-22 15:00:00 +0300
categories: [Open Source]
tags: [Open Source]
---

Minecraft's inventory and chest UI gives you no built-in way to organize
stacks — items pile up in whatever order you happened to pick them up. Most
existing sorting mods solve that by bundling an entire
inventory-management suite: custom storage systems, new UI overlays,
crafting changes, more surface area than the actual problem needs. Easy
Sort is the opposite bet — one hotkey, sorts the container you're looking
at, and otherwise gets out of the way. It was also a deliberate way to
learn Java and Minecraft's modding APIs from scratch, on a project
deliberately scoped small enough to actually finish and ship, rather than
sprawl into something I'd abandon halfway.

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

It's now a stable, actively maintained mod (currently v1.4.1) supporting
every chest-type container — chests, double chests, barrels, trapped
chests, ender chests, minecarts, shulker boxes — plus Quick Stack and
Restock, published on both Modrinth and CurseForge, across both the Fabric
and NeoForge mod loaders.

## One hard rule that made "add NeoForge later" actually easy

The project is a multi-module Gradle build (via Architectury Loom) with
three modules — `common`, `fabric`, and `neoforge` — under one rule
enforced at the build level, not just as a convention: **`common/` may
import zero Minecraft or loader-specific classes.** All the sorting logic
lives in `common/` as plain Java operating on abstracted inventory data;
`fabric/` and `neoforge/` each provide only the thin per-loader glue
(mixins, event registration, networking) needed to wire that logic into
their respective modding APIs.

I made that a build-system rule instead of a convention deliberately — a
convention gets violated the first time it's inconvenient, usually late at
night with a deadline. Making the constraint enforced means a stray import
that would silently couple shared logic to one loader's API gets caught
immediately, at compile time, rather than discovered later when the other
loader's build mysteriously breaks or the two implementations quietly
diverge. When NeoForge support actually got added, it was writing the
adapter layer, not rewriting the sorting logic.

## Server-authoritative sorting, even in singleplayer

The other decision I'd make again without hesitation: pressing the hotkey
sends a small "sort this container" *intent* packet to the server, which
re-validates the request and performs the actual sort, then does a full
menu resync back to the client — instead of sorting client-side and hoping
the server agrees. Even singleplayer runs an internal server under the
hood, so this path is never skipped, not even as an optimization.

The reason: "simple" client-side sorting mods are a classic source of item
duplication and desync bugs in multiplayer. The client and server
disagreeing about a container's contents, even for a moment, is enough to
duplicate or lose items — and that class of bug is exactly the kind that's
invisible in solo testing and devastating on a shared server. Treating the
hotkey press as a request rather than an action, and letting the server own
the actual mutation, closes that entire bug category rather than trying to
catch instances of it after the fact.

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

## Shipping a mod is a different job than writing one

The part I underestimated going in: publishing to Modrinth and CurseForge
via CI, and maintaining support across several actively-diverging Minecraft
versions — with older branches frozen rather than back-ported indefinitely
— turned "write a mod" into "maintain a small piece of infrastructure."
Version-matrix support and an actual release process (`CHANGELOG.md`,
`ROADMAP.md`, SemVer discipline) ended up being as much ongoing work as the
original sorting feature itself. That's not a complaint — it's the part of
"actively maintained" that doesn't show up when you're scoping the initial
feature, and it's the part that separates a mod people can rely on from one
that quietly breaks the next time Mojang ships an update.

Full architecture write-up is on the
[project page](/blog-site/projects/easy-sort/); source is on
[GitHub](https://github.com/imndllnuri/easy-sort), and the mod itself is on
[Modrinth](https://modrinth.com/mod/easy-sort) and
[CurseForge](https://www.curseforge.com/minecraft/mc-mods/easy-sort).
