# MyAltManager — World Events & Weekly Quests in the drawer (Implementation Instructions)

> **Purpose:** split the drawer's single flat `WEEKLIES` list into **World Events** and **Weekly
> Quests**, mark every entry with a real WoW texture, and give the footer the weekly reset. This
> document is the authoritative build spec for that work.
> **Target design:** **W-2** — two groups on one shared six-column grid, three status icons (no red
> cross), entries ordered *complete → in progress → not picked up*, currencies out of the drawer,
> footer carrying version on the left and weekly reset on the right.
> **Addon source:** `C:\git\myaltmanager` — single Lua file `MyAltManager.lua` (2469 lines),
> `MyAltManager.toc` at Interface **120007**, version **12.1.0.7**.
> **Design reference:** https://claude.ai/code/artifact/0f814fc0-4c8f-4a50-bf14-6b033ef26bd1
> **Companion spec:** `C:\git\mam2\implementation.md` (the 13-A row rebuild). This file continues
> its conventions; IDs here are prefixed `EV-` so the two never collide.

## How to use this file

- Work the phases in order. **Phase 0 is a hard blocker** — nothing in this feature is visible until
  it is done.
- Each task has a stable ID (`EV-DATA-1`, `EV-DRAW-3`, …). Reference the ID in commit messages.
- Tick a box only when the change is written **and** verified in-game (`/reload`, then exercise the
  path in **Verify**).
- **Do not invent APIs.** Every API used below is in Appendix C with its return shape. Anything not
  listed gets verified against `C:\git\wow-interface-code` before it is written.
- Line numbers below are against v12.1.0.7 and will drift as you edit. They are there to find the
  code, not to be trusted after the first change.
- Bump `## Version:` in the TOC with every push → **12.1.0.8**.

---

## The target layout (visual contract)

```
├──────────────────────────────────────────────────────────────────────────────────────┤
│ ▌Rimebound ⊘          │   2648   │ RAIDS    [200][213][226]│ [✦][22/22 ] [A][90/90 ] │
│ ▌Aman'Thul · 236 ilvl │+12 Duskm.│ DUNGEONS [200][210][220]│ [V][90/90 ] [C][90/90 ] │
│ ▌Tier Set: 4/5 · …    │          │ OUTDOORS [197][204][213]│ [H][64/90 ] [M][12/90 ] │
├──────────────────────────────────────────────────────────────────────────────────────┤
│  WORLD EVENTS — 2/4 COMPLETE                                    (drawer, when open)   │
│  ✓ Abundant Offer…  ✓ Stormarian As…  ? Legends of the…  ! Sath'theril So…            │
│  WEEKLY QUESTS — 2/5 COMPLETE                                                         │
│  ✓ Special Assign…  ✓ World Boss      ? A Nightmarish …  ? Weekly Meta Qu…  ! Hidden… │
├──────────────────────────────────────────────────────────────────────────────────────┤
│ My Alt Manager · v12.1.0.8                                     Weekly reset in 3d 06h │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

Rules the implementation must honour:

1. **Two groups, not one.** `WORLD EVENTS` (4 entries) then `WEEKLY QUESTS` (5). Counts in the
   headings are derived from the section children — never hardcoded.
2. **One shared six-column grid.** Both groups call `AddGrid(entries, 6)`. Same column count, same
   cell metrics, so the icon in column *n* of one group sits directly above column *n* of the other.
   **The alignment is the point of this layout.** If a change would break it, the change is wrong.
3. **Three icon states, not four.** Tick (complete), gold `?` (in progress), gold `!` (not picked
   up). No red cross anywhere in this drawer.
4. **Order is `complete → inprogress → notstarted`, then alphabetical by label** inside each band.
5. **Labels are not colour-coded.** The icon carries the state; every label renders in
   `constants.colors.body`, except completed entries which dim to `muted`.
6. **No currencies and no PvP in the drawer.** The drawer answers one question: what this character
   still owes the week.
7. **No `OnUpdate` anywhere.** The reset string refreshes on rebuild and on a 60-second ticker at
   most.
8. **No POI / world-state lookups.** Every state shown is a quest-log fact (see `EV-DATA-1`).

---

## PHASE 0 — Unblock the drawer (do this first)

### `EV-0` — The drawer is currently force-disabled in code
- [ ] `LoadConfigFromDB()` (~line 658) **overwrites the saved setting on every login**:
      ```lua
      db.config.enable_drawer = false      -- line 669: unconditional, ignores the DB
      db.config.openRows = {}              -- line 670: wipes persistence every load
      ...
      constants.config.ENABLE_DRAWER = false   -- line 677: unconditional
      ```
      Replace with a normal load-with-default:
      ```lua
      if db.config.enable_drawer == nil then db.config.enable_drawer = true end
      db.config.openRows = db.config.openRows or {}
      ...
      constants.config.ENABLE_DRAWER = db.config.enable_drawer and true or false
      ```
- [ ] `constants.config.ENABLE_DRAWER = false` at line 92 becomes the *default before DB load*, not
      the answer. Leave the declaration; `LoadConfigFromDB` now supplies the real value.
- **Why this is first:** `RebuildUI` only acquires a drawer when
  `constants.config.ENABLE_DRAWER and openRows[guid]` (line 2367), and `ConfigureRowInteractions`
  (line 1890) only attaches the click handler under the same flag. With the flag pinned off, every
  task below renders to nothing and you will debug the wrong file.
- **Do not** remove the flag. Rows must still be inert when it is off — that requirement stands
  (`DRAWER-1` in the companion spec).
- **Verify:** `/reload`, click a character row — it expands. Open two, `/reload` — both reopen.

---

## PHASE 1 — Data: teach the collectors a third answer

### `EV-DATA-1` — Eight of the nine weeklies can never report "in progress"
- [ ] **This is the one real data change and the easiest to miss.** Today only
      `checkWeeklyMetaQuestStatus` (line 1143) returns three states. The other eight are binary and
      can only ever emit `complete` / `incomplete`, so a drawer built on them would *never* show a
      gold `?`.
- [ ] Add one shared helper next to the existing collectors and route all nine through it:
      ```lua
      local function QuestSetStatus(questIDs)
          local inProgress = false
          for _, questID in ipairs(questIDs) do
              if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                  return "complete"                     -- checked first: a turned-in quest
              elseif C_QuestLog.IsOnQuest(questID) then --  is no longer in the log
                  inProgress = true
              end
          end
          return inProgress and "inprogress" or "notstarted"
      end
      ```
- [ ] Convert these, all currently two-state:

  | Collector | Line | Quest IDs |
  |---|---|---|
  | `checkSpecialAssignmentStatus` | ~1165 | existing 12-ID list |
  | `checkSaththerilSoireeStatus` | ~1177 | existing 4-ID list |
  | `checkWorldBossStatus` | ~1187 | existing 4-ID list |
  | `abundantOfferings` (inline) | ~1247 | `{ 89507 }` |
  | `stormarianAssault` (inline) | ~1248 | `{ 94581 }` |
  | `legendsOfTheHaranir` (inline) | ~1249 | `{ 89268 }` |
  | `hiddenTrove` (inline) | ~1251 | `{ 86371 }` |
  | `nightmarishTask` (inline) | ~1252 | `{ 94446 }` |

- [ ] `checkWeeklyMetaQuestStatus` collapses into `QuestSetStatus(...)` with its existing ID list —
      it is already exactly this logic.
- **`checkWorldBossStatus` keeps its stored-completion guard, and the guard stays first.** That
  early return exists because the world-boss flag drops out of the quest log after login; putting
  the new branch ahead of it would resurrect the bug it was written to fix:
  ```lua
  local function checkWorldBossStatus()
      -- existing stored-complete scan stays exactly here, unchanged
      ...
      return QuestSetStatus({ 92034, 92636, 92560, 92123 })
  end
  ```
- **Verify:** pick up (do not complete) a weekly on a test character, `/reload`, open its drawer —
  that entry shows the gold `?`. Abandon it — it returns to gold `!`.

### `EV-DATA-2` — Old saved data still says "incomplete"
- [ ] **No schema bump.** The `weeklies` array shape is unchanged (line 1323); only the set of
      possible status strings widens. Bumping `DATA_SCHEMA` would blank every alt for no gain.
- [ ] Alts that have not logged in since this change still carry `"incomplete"`. Map it at render
      time, in the drawer only:
      ```lua
      local status = statusByKey[child.dataKey] or "notstarted"
      if status == "incomplete" then status = "notstarted" end
      ```
- **Why `notstarted` and not something louder:** "not complete" and "not picked up" are the same
  thing for a weekly in every case but one (an event that is not currently up), and this drawer
  deliberately does not model that case. The value self-heals the next time that character logs in.
- **Verify:** an alt last seen before the change shows gold `!` entries, not blanks and not errors.

---

## PHASE 2 — Split the section

### `EV-SECT-1` — Add `world_events`, shrink `weekly_quests`
- [ ] `constants.labels.WEEKLY_EVENTS = "Weekly Events"` already exists at line 99 and **nothing
      renders it**. This is what it was for. Use it as the section label.
- [ ] Insert a `world_events` section into `constants.sections` **immediately before**
      `weekly_quests`, and move four children across:

  | Section | Children (`key` → `dataKey`) |
  |---|---|
  | `world_events` | `saththeril_soiree` → `saththerilSoiree` · `stormarian_assault` → `stormarianAssault` · `legends_of_the_haranir` → `legendsOfTheHaranir` · `abundant_offerings` → `abundantOfferings` |
  | `weekly_quests` | `weekly_meta_quest` → `weeklyMetaQuest` · `special_assignment` → `specialAssignment` · `hidden_trove` → `hiddenTrove` · `nightmarish_task` → `nightmarishTask` · `world_boss` → `worldBoss` |

- [ ] Move the matching strings out of `weekly_quests.keys` into `world_events.keys` as well — the
      `keys` array feeds `section_lookup`, and a key left in the wrong list makes `IsRowVisible`
      answer for the wrong section.
- **Nothing else needs touching.** `section_lookup`, `child_lookup` and `section_keys` are built by
  the loop at line 202 and pick the new section up for free, and `RegisterSettings` (line 729)
  iterates `constants.sections` to generate toggles — so the settings panel gains
  **Show Weekly Events** plus four child checkboxes with no settings code at all.
- **Verify:** Settings → MyAltManager lists both sections; unticking *Show Weekly Events* hides that
  group and leaves Weekly Quests intact; unticking one child hides one entry and decrements the
  heading count.

### `EV-SECT-2` — Confirm the split against the live game before shipping
- [ ] The four/five split above is inferred from the names, not observed in game. **Abundant
      Offerings is the least certain** — if it turns out to be a plain weekly quest rather than a
      rotating zone event, move that one row between the two tables in `EV-SECT-1`.
- **Nothing else changes if the split is wrong** — that is deliberate. The grouping is data, not
  logic; no code below branches on which section an entry belongs to.

---

## PHASE 3 — Status icons

### `EV-ICON-1` — Replace the glyphs with game textures
- [ ] `STATUS_STYLES` (line 1458) keeps its four keys and its `color` field. Only `glyph` changes,
      to a texture escape — the same `|T…|t` form already used throughout `constants.labels`:

  | Status | Texture | Escape |
  |---|---|---|
  | `complete` | ready-check tick | `\|TInterface\RaidFrame\ReadyCheck-Ready:12:12:0:0\|t` |
  | `inprogress` | gold `?` | `\|TInterface\GossipFrame\ActiveQuestIcon:12:12:0:0\|t` |
  | `notstarted` | gold `!` | `\|TInterface\GossipFrame\AvailableQuestIcon:12:12:0:0\|t` |
  | `incomplete` | ready-check cross | `\|TInterface\RaidFrame\ReadyCheck-NotReady:12:12:0:0\|t` |

- [ ] **Keep `incomplete` in the table even though this drawer never emits it.** It is the only
      state that can express "not available", and it costs one line to leave in place.
- **No new art.** All four ship with the game; `media/` gains nothing and there is nothing to keep
  in sync across patches.
- **Verify:** all three states render as icons at 12 px with no baseline wobble against 9.5 px text.

### `EV-ICON-2` — The icon carries the state, so stop colouring the label
- [ ] In the drawer's entry build, pass `constants.colors.body` for every entry instead of
      `style.color`, and `constants.colors.muted` for `complete`. Nine entries in four colours reads
      as a traffic light; nine entries in one colour with three icons reads as a list.
- **Alignment falls out of this for free and must not be re-engineered.** A `|T…:12:12:0:0|t` prefix
  occupies exactly 12 px regardless of state, so every label starts at the same offset inside its
  cell, and `AddGrid` already left-aligns cells at fixed x positions. **Do not add separate icon
  frames or a two-column sub-layout per cell** — the escape is what makes the columns line up, and
  it costs zero extra `FontString`s.
- **Verify:** with a mix of states across both groups, the icons form clean vertical columns and the
  labels form a second set of clean columns.

---

## PHASE 4 — The drawer

### `EV-DRAW-1` — Two groups in place of one
- [ ] Replace the single `weekly_quests` block in `ConfigureDrawer` (lines 2222–2246) with two
      passes over the same code path — one for `world_events`, one for `weekly_quests`:
      `WORLD EVENTS — <n>/<total> COMPLETE`, then `WEEKLY QUESTS — <n>/<total> COMPLETE`.
- [ ] **Kill the hardcoded `/9`** at line 2243. Both totals come from the count of *visible*
      children in that section, so a child hidden in settings leaves the denominator honest.
- [ ] Each group is gated by its own `self:IsRowVisible(sectionKey)`, and each entry by
      `self:IsRowVisible(child.key)`, exactly as the current code does.
- **Factor the shared work into one local** taking `(sectionKey, headingText)` rather than
  copy-pasting the block. The two groups must not be able to drift apart.
- **Verify:** heading counts match the number of ticks below them, in both groups, on three
  characters at different stages of the week.

### `EV-DRAW-2` — Ordering
- [ ] Sort a **copy** of the children at render time. Do not reorder `constants.sections` — that
      table drives the settings panel, where a stable hand-picked order reads better.
      ```lua
      local ORDER = { complete = 1, inprogress = 2, notstarted = 3, incomplete = 3 }
      table.sort(entries, function(a, b)
          local ra = ORDER[a.status] or 99
          local rb = ORDER[b.status] or 99
          if ra ~= rb then return ra < rb end
          return a.label < b.label
      end)
      ```
- **Three traps here, all of which have bitten this pattern before:**
  - Default an unknown status to a rank rather than `nil`, or the comparison errors on arithmetic
    against nil instead of just sorting oddly.
  - `table.sort` is **not stable**, so the comparator must be total — it must never return `true`
    for both orderings of a pair, or Lua can raise *invalid order function for sorting* outright.
  - Sort on `label`, not on `key` or `dataKey`. `saththerilSoiree` and `"Sath'theril Soiree"` do not
    order the same way, and `nightmarishTask` vs `"A Nightmarish Task"` differ more.
- **Verify:** complete a weekly in game, `/reload` — that entry moves to the front of its group and
  dims; the entries behind it keep their relative alphabetical order.

### `EV-DRAW-3` — Six columns
- [ ] Both groups call `AddGrid(entries, 6)`. `AddGrid` (line 2199) already takes a column count and
      divides the available width evenly, so **this is an argument change, not new layout code**.
- **The fit is tight but real, and here is the arithmetic so you can re-check it after any width
  change:** `innerWidth` = 870 − (2 × 14) = **842**; `AddGrid`'s `availableWidth` = 842 − 24 =
  **818**; at 6 columns that is **136.3 px** per column and a **128.3 px** cell. The longest label,
  *Legends of the Haranir*, is ≈ 105 px at the existing 9.5 px drawer font, plus a 12 px icon and a
  space — ≈ 120 px. It fits with ~8 px to spare.
- [ ] If a future event name is longer than the Haranir, the fix is **five columns or an ellipsis —
      never a wider cell**, because unequal cells destroy the cross-group alignment this layout
      exists for.
- **Verify:** at 6 columns no label truncates on any character; events occupy columns 1–4 and quests
  columns 1–5, with the icons aligned between the two rows.

### `EV-DRAW-4` — Currencies and PvP leave the drawer
- [ ] The currencies block (line 2248) and the PvP block (line 2266) are already wrapped in
      `IsRowVisible` checks, so this is a **default change, not a deletion**. Leave both code paths
      intact.
- [ ] **Split the `currencies` flag in two first.** Right now one key governs the drawer's currency
      list *and* the season currency grid in the row — it is the same key behind
      `GetColumnLayout`'s `currency.visible` at line 1532 — so defaulting it off would take every
      character's crest bars with it. Add a separate `drawer_currencies` visibility key, default
      `false`, and switch the drawer block to it. The row keeps `currencies`.
- [ ] `pvp` is already its own section with its own toggle and has no presence in the row, so it
      needs no split — just default `MyAltManagerDB.visibility.pvp = false`.
- **Verify:** the drawer shows exactly two groups; the row still shows all six crest bars; ticking
  *Show Currencies* in settings changes the row and not the drawer.

### `EV-DRAW-5` — Height
- [ ] `ConfigureDrawer` already returns a content-driven height and `RebuildUI` already sums it into
      the frame (lines 2370–2374). Two groups of one grid row each should land at **~50 px** open,
      against ~120 px today.
- **Verify:** open all three drawers on a three-character roster — the window grows by roughly
  150 px total and the footer stays anchored below the scroll frame.

---

## PHASE 5 — The footer

### `EV-FOOT-1` — Split the single centred string into two
- [ ] `frame.footerText` is created centred in `InitializeFrame` (lines 1691–1694). Replace it with
      two `FontString`s on the existing `frame.footer`:
      - `footerVersion` — `BOTTOMLEFT`, inset by `layout.PAD_X`, text `"My Alt Manager · v" ..
        constants.VERSION`, colour `muted`.
      - `footerReset` — `BOTTOMRIGHT`, inset by `layout.PAD_X`, right-justified, colour `muted` with
        the duration itself in `body` so it reads as a value rather than chrome.
- [ ] The footer's `SetPoint`/`SetSize` in `RebuildUI` (lines 2387–2389) stays as it is; only the
      children change.
- **Verify:** at 870 px the two strings never collide; the version reads bottom-left and the reset
  bottom-right, both vertically centred in the 18 px footer.

### `EV-FOOT-2` — The reset value
- [ ] Use `C_DateAndTime.GetSecondsUntilWeeklyReset()` directly — the same call
      `GetNextWeeklyResetTime()` (line 2465) already wraps. Format as `Weekly reset in 3d 06h`,
      dropping to `6h 12m` under a day and `48m` under an hour.
- [ ] Guard the nil/zero return exactly as `GetNextWeeklyResetTime` does; on nil, hide the string
      rather than printing `0d 00h`.
- [ ] Refresh on `RebuildUI`, plus a **single `C_Timer.NewTicker(60, …)`** if you want it live while
      the window sits open. Store the handle and `:Cancel()` it in `HideInterface`.
- **No `OnUpdate`, at any interval, anywhere.** There is nothing here that needs per-frame or
  per-second resolution, and a footer that reformats a string every frame is the classic way an alt
  manager ends up on someone's addon-CPU screenshot.
- **Verify:** `/reload` on a Tuesday and again on a Sunday — the format switches from days to hours
  correctly; open the window for two minutes and watch the minute value change once.

---

## PHASE 6 — Settings

### `EV-SET-1` — New keys
- [ ] `drawer_currencies` → default `false` (`EV-DRAW-4`).
- [ ] `MyAltManagerDB.visibility.pvp` → default `false`.
- [ ] `enable_drawer` → default `true` (`EV-0`).
- [ ] Seed all three in `InitDB()` (line 879) **and** default them in `LoadConfigFromDB()`, so an
      existing SavedVariables file picks them up without a wipe.

### `EV-SET-2` — The section toggles come free
- [ ] Nothing to write. `RegisterSettings` builds parent + child checkboxes from
      `constants.sections`, so `world_events` and its four children appear automatically once
      `EV-SECT-1` lands.
- **Verify:** the child checkboxes grey out when their parent is unticked — that is
  `SetParentInitializer` at line 758 and it should keep working unchanged.

---

## Acceptance checklist

- [ ] Clicking a row opens a drawer; two drawers survive `/reload` still open.
- [ ] The drawer shows exactly two groups: `WORLD EVENTS — n/4` and `WEEKLY QUESTS — n/5`.
- [ ] No currencies, no PvP, and **no red cross** anywhere in the drawer.
- [ ] Every entry carries one of three textures; every label is `body`, or `muted` when complete.
- [ ] Icons form clean vertical columns **across both groups**.
- [ ] Entries run complete → in progress → not picked up, alphabetical inside each band.
- [ ] Heading counts equal the number of ticks beneath them, and follow child visibility.
- [ ] A quest picked up but unfinished shows the gold `?` — on **all nine**, not just the meta quest.
- [ ] The footer reads version bottom-left, `Weekly reset in …` bottom-right.
- [ ] `/dump` finds no `OnUpdate` registered by this feature and no `C_AreaPoiInfo` call anywhere.
- [ ] Unticking *Show Weekly Events* hides one group; unticking a child decrements one denominator.
- [ ] `enable_drawer` off ⇒ rows inert, no highlight, drawer pool `GetNumActive()` is 0.
- [ ] An alt not logged in since the change renders without errors.
- [ ] TOC version bumped to 12.1.0.8.

---

## Appendix A — The nine, regrouped

| Group | Label | `dataKey` | Quest IDs |
|---|---|---|---|
| World Events | Sath'theril Soiree | `saththerilSoiree` | 90573–90576 |
| World Events | Stormarian Assault | `stormarianAssault` | 94581 |
| World Events | Legends of the Haranir | `legendsOfTheHaranir` | 89268 |
| World Events | Abundant Offerings | `abundantOfferings` | 89507 — *verify, see `EV-SECT-2`* |
| Weekly Quests | Weekly Meta Quest | `weeklyMetaQuest` | 13-ID list, line 1145 |
| Weekly Quests | Special Assignment | `specialAssignment` | 12-ID list, line 1166 |
| Weekly Quests | Hidden Trove (Delves) | `hiddenTrove` | 86371 |
| Weekly Quests | A Nightmarish Task | `nightmarishTask` | 94446 |
| Weekly Quests | World Boss | `worldBoss` | 92034, 92636, 92560, 92123 |

## Appendix B — Colour tokens (all already in `constants.colors`)

This feature introduces **no new hex values**. State colour now lives in the textures, so the
drawer's palette gets smaller, not bigger.

| Element | Constant | Value |
|---|---|---|
| Group headings | `drawerHeading` | `#B7B0C1` |
| Count suffix in headings | `muted` | `#90899A` |
| Entry labels — all three states | `body` | `#C5C0CD` |
| Completed entries, dimmed | `muted` | `#90899A` |
| Footer version, footer label text | `muted` | `#90899A` |
| Footer reset duration | `body` | `#C5C0CD` |
| Drawer top rule, footer top rule | `drawerDivider` | `#322C3C` |

## Appendix C — Verified API reference

Confirm anything not on this list against `C:\git\wow-interface-code` before using it.

**Quest state** — the only source this feature reads from
- `C_QuestLog.IsQuestFlaggedCompleted(questID)` → boolean. Already used throughout `CollectData`.
- `C_QuestLog.IsOnQuest(questID)` → boolean. Already used by `checkWeeklyMetaQuestStatus` (line 1153).

**Time**
- `C_DateAndTime.GetSecondsUntilWeeklyReset()` → number, **can be nil or ≤ 0** — guard it, as
  `GetNextWeeklyResetTime()` (line 2465) already does.
- `C_Timer.NewTicker(seconds, callback)` → ticker handle with `:Cancel()`.

**Textures in strings**
- `|Tpath:width:height:xOffset:yOffset|t` inline escape in any `FontString`. Already used by every
  currency label in `constants.labels` (lines 109–142).

**Settings** — no new calls needed; `RegisterSettings` (line 680) generates everything from
`constants.sections`.

**Explicitly not used by this feature:** `C_AreaPoiInfo.*`, `AREA_POIS_UPDATED`,
`C_TaskQuest.GetQuestTimeLeftSeconds`. Dropping the red cross removed the need for world state, and
with it a dependency on POI IDs that get retired between patches. **Do not reintroduce them** unless
you are deliberately adding the event-timer tooltip described below.

## Appendix D — Execution order

1. `EV-0` — unblock the drawer. Nothing below is visible until this lands.
2. `EV-DATA-1` — the collectors. Verify with `/dump MyAltManagerDB.data` before touching any UI.
3. `EV-SECT-1` — the split. Check the settings panel, not the drawer.
4. `EV-ICON-1` / `EV-ICON-2` — icons into the existing single group. Stop and look at it.
5. `EV-DRAW-1` → `EV-DRAW-3` — two groups on the six-column grid.
6. `EV-DRAW-4` — take currencies and PvP out, after splitting the flag.
7. `EV-FOOT-1` / `EV-FOOT-2` — the footer.
8. `EV-DATA-2` and `EV-SET-1` — the migration and defaults, last, once the shape is settled.

## Appendix E — What must not change

- The `weeklies` storage shape (line 1323) and `DATA_SCHEMA`. Only the set of status strings widens.
- `constants.sections` as the single source of labels and visibility keys. **No second hand-written
  list of the nine anywhere in the render path.**
- The `enable_drawer` flag as a real toggle. `EV-0` fixes how it is loaded, not whether it exists.
- The row itself — this feature touches the drawer, the footer, and eight collectors. Nothing in
  `ConfigureCharacterCell` / `ConfigureMythicCell` / `ConfigureVaultCell` / `ConfigureCurrencyCell`
  should need editing.

## Appendix F — Deliberately out of scope

**W-2 shows that an event is not done; it does not show whether that event is up right now.** An
event you have not picked up looks identical whether it spawns in two minutes or six hours. That is
the accepted cost of dropping the red cross, and it is what buys the quest-log-only data path.

If that turns out to matter in play, the fix is a **tooltip, not a grid change**: `OnEnter` on the
entry's `FontString`, one `GameTooltip` line from `C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)`,
computed once on hover. Every cell keeps its width, the alignment survives, and there is still no
`OnUpdate`. Treat that as a separate change with its own ID — do not smuggle it into this one.
