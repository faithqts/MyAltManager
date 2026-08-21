# MyAltManagerWebsite

## Context

`MyAltManager` (`C:\git\MyAltManager\MyAltManager.lua`, 3661 lines, single file, no libraries) records per-character weekly progress into `MyAltManagerDB` and renders it in one in-game window. Two limitations motivate this work:

1. **The data is trapped in the client.** There is no export path of any kind — grep for `base64|serialize|export|encode|LibDeflate` across the repo returns zero hits, and no `EditBox` is ever created. You cannot look at your roster without launching WoW.
2. **Storage is gated.** `AltManager:StoreData` (`MyAltManager.lua:1257-1294`) drops any character below `MIN_LEVEL` (90) or `MIN_ITEM_LEVEL` (240). Bank alts and levelling crafters are invisible to the addon, which is exactly the population you care about for crafting concentration — concentration caps at 1000 and silently wastes regen once full, and it accrues on characters you rarely log into.

The outcome: a self-hosted Vue site that accepts a base64 export string pasted anywhere on the page, persists it to `localStorage`, renders everything the addon already tracks, and adds a concentration dashboard covering **every** character the addon has ever seen — including untracked ones — with live-projected values and time-to-cap.

### Decisions already made

| Decision | Choice |
|---|---|
| Storage | `localStorage` only. Node serves static files. **No database.** |
| Account scope | Single account. Import replaces the snapshot; no profile switcher. |
| Merge policy | Per-character `lastSeen` wins — a stale export never clobbers a fresher character. |
| Concentration scope | New **unfiltered** `MyAltManagerDB.roster` table, written for every character regardless of level/ilvl. Existing `data` table untouched. |
| Concentration display | Project the live value from the snapshot; show time-to-cap and a capped warning. |
| Export encoding | Vendor `LibDeflate` + hand-rolled JSON and standard base64. `MAM1:` + base64(zlib(json)). |

---

## Verified API facts

Checked against `C:\git\wow-interface-code` (per the "do not invent APIs" rule in `events.md`):

| API | Location | Note |
|---|---|---|
| `C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)` → `currencyType` | `TradeSkillUIDocumentation.lua:142` | Returns `0` when the line has no concentration. |
| `C_TradeSkillUI.GetAllProfessionTradeSkillLines()` → `{skillLineID}` | `TradeSkillUIDocumentation.lua:106` | Works without the trade skill window open. |
| `C_TradeSkillUI.GetProfessionInfoBySkillLineID(id)` → `ProfessionInfo` | `TradeSkillUIDocumentation.lua:473` | |
| `ProfessionInfo` fields | `TradeSkillUITypesDocumentation.lua:360-375` | `professionID`, `professionName`, **`expansionName`**, `skillLevel`, `maxSkillLevel`, `isPrimaryProfession`, `parentProfessionID` |
| `C_CurrencyInfo.GetCurrencyInfo(id)` | `CurrencyInfoDocumentation.lua:690-709` | `quantity`, `maxQuantity`, `discovered`, **`rechargingCycleDurationMS`**, **`rechargingAmountPerCycle`** |
| `C_SpecializationInfo.GetSpecialization()` | `SpecializationInfoDocumentation.lua:197` | |

**The regen rate is available from the API.** `rechargingCycleDurationMS` / `rechargingAmountPerCycle` are non-nilable fields on `CurrencyInfo`, and Blizzard's own `ProfessionsCurrencyMixin:SetCurrencyType` (`Blizzard_ProfessionsTemplates.lua:749`) drives its refresh ticker off exactly that field. Export both — the website never hardcodes "1 per 6 minutes", so a Blizzard tuning change flows through automatically.

`C:\git\FaithsCraftAssist` confirms the discovery pattern works in practice (`FaithsCraftAssist.lua:554-604`) but **persists nothing** — it is a live pixel-signal emitter, so there is no code to reuse there, only the recipe. Two things it does that we should not copy: its "highest `skillLineID` wins" expansion heuristic (`:571`) is fragile — we store every expansion line instead; and it never reads `maxQuantity` or the recharge fields at all.

---

## Part 0 — Inventory of everything currently tracked

Exhaustive as of `MyAltManager.toc` version `12.1.0.43` / `DATA_SCHEMA = 2` / `ACTIVE_SEASON_ID = 2`. Every field below is written in exactly one place: the `char_table` literal at `MyAltManager.lua:1548-1637`, inside `AltManager:CollectData()`.

### 0.1 Per-character record — `MyAltManagerDB.data[<playerGUID>]`

Keyed by `UnitGUID("player")` (e.g. `Player-3725-0A8145B7`). Written only via `AltManager:StoreData` (`:1257-1294`), which **replaces the whole record** — it never merges.

#### Identity and record metadata

| Field | Type | Source | Notes |
|---|---|---|---|
| `guid` | string | `UnitGUID("player")` | Also the table key. Encodes realm ID (`3725`) but not region. |
| `name` | string | `UnitName("player")` | Unqualified — no realm suffix. |
| `realmName` | string | `GetRealmName()` | **Unnormalized** — retains spaces/apostrophes. |
| `class` | string | `select(2, UnitClass("player"))` | Token, e.g. `DEMONHUNTER`, `DEATHKNIGHT`. |
| `charLevel` | number | `UnitLevel("player")` | |
| `ilevel` | number | `math.floor(select(2, GetAverageItemLevel()))` | Equipped average only. |
| `schema` | number | `constants.DATA_SCHEMA` (`:20`) | Currently `2`. Records below this are **deleted** by `MigrateDataSchema` (`:543-563`). |
| `seasonID` | number | `constants.SEASON_ID` | Currently `2`. |
| `version` | string | `constants.VERSION` | Addon version at time of capture. |
| `dataObtained` | number | `time()` | UTC epoch seconds. The only freshness marker. |
| `expires` | number | `GetNextWeeklyResetTime()` (`:3657`) | UTC epoch of next weekly reset; drives `ValidateReset` (`:1179`). |

#### Tier set and catalyst

| Field | Type | Source | Notes |
|---|---|---|---|
| `tierPieces` | number | `GetTierBonuses()` (`:1663`) | Capped at 5. Counts equipped **and** bagged pieces. |
| `tierSlots` | array\<string> | `GetTierBonuses()` | Sorted display strings only — `"Helm"`, `"Shoulders"`, `"Chest"`, `"Pants"`, `"Gloves"`, or `"Stored tier piece"`. Slot IDs and item IDs are discarded. Empty on all 13 current characters. |
| `catalyst.current` | number | `GetCurrencyInfo(currencies.catalyst).quantity` | S2 currency `3465`. |
| `catalyst.max` | number | `GetCurrencyInfo(currencies.catalyst).maxQuantity` | |

Tier detection scans equipment slots `constants.TIER_SLOTS` = `{1 Helm, 3 Shoulders, 5 Chest, 7 Pants, 10 Gloves}` plus `BACKPACK_CONTAINER`..`NUM_BAG_SLOTS`, matching `select(16, C_Item.GetItemInfo(id))` against `constants.TIER_SETS`.

#### Mythic+

| Field | Type | Source | Notes |
|---|---|---|---|
| `mplus.score` | number | `C_ChallengeMode.GetOverallDungeonScore()` | |
| `mplus.r` / `.g` / `.b` | number | `C_ChallengeMode.GetDungeonScoreRarityColor()` | **Presentation stored as data** — the score's display colour, 0–1. |
| `mplus.keyMapID` | number? | `C_MythicPlus.GetOwnedKeystoneChallengeMapID()` | **Stripped at weekly reset** (`:1188`) — key may be absent. |
| `mplus.keyLevel` | number? | `C_MythicPlus.GetOwnedKeystoneLevel()` | Same. |
| `runHistory` | array | `C_MythicPlus.GetRunHistory(false, true)` | **Set to `nil` at weekly reset** (`:1186`) — the key can be genuinely absent. Empty on all 13 current characters. |

`constants.DUNGEONS` (`:263-345`) maps 80+ `mapID`s to short display names; `GetDungeonShortName` (`:495`) prefers the active season's `MAPS` table. Season 2 maps: `584 Vale`, `585 Voidscar`, `586 Den`, `587 Murder`, `588 Fangs`.

#### Great Vault — `vault.{raid,dungeon,world}`

Three tracks × three slots, each from `CollectVaultTrack` (`:1296-1326`) over `C_WeeklyRewards.GetActivities()`.

| Track | `Enum.WeeklyRewardChestThresholdType` | Fallback thresholds | `activityID`s seen |
|---|---|---|---|
| `raid` | `.Raid` | `{2, 4, 6}` | 210, 211, 212 |
| `dungeon` | `.Activities` | `{1, 4, 8}` | 213, 214, 215 |
| `world` | `.World` | `{2, 4, 8}` | 207, 208, 209 |

Per slot: `progress`, `threshold`, `earned` (bool), `ilvl` (only when `earned`, via `GetExampleRewardItemHyperlinks` + `C_Item.GetDetailedItemLevelInfo`), `activityID`, `raidString` (raid track only, e.g. `"Defeat %d Midnight Season 2 |4Boss:Bosses"`). Reset to empty tracks by `CreateEmptyVaultTrack` (`:1148`).

#### Season currencies — `season.*`

Each is a **positional 2-element array `{current, rollingMax}`** from `GetRollingCurrencyValues` (`:1469-1490`), which accounts for spent currency: when `useTotalEarnedForMaxQty` it returns `{totalEarned, maxQuantity}`, otherwise `{quantity, max(quantity, maxQuantity - spent)}`.

| Store key | S2 currency ID | S1 currency ID | Label |
|---|---|---|---|
| `season.sparks` | `3509` (Tidal Sparks) | `3212` (Radiant Sparks) | Sparks |
| `season.adventurer` | `3442` | `3383` | Adventurer Crests |
| `season.veteran` | `3443` | `3341` | Veteran Crests |
| `season.champion` | `3444` | `3343` | Champion Crests |
| `season.hero` | `3445` | `3345` | Hero Crests |
| `season.myth` | `3446` | `3347` | Myth Crests |

#### Weekly quests and events — `weeklies`

An **ordered array of 11 entries**, each `{ key, status, progressType?, progress?, required? }`. Order is load-bearing — `CreateResetWeeklies` (`:1163-1177`) rebuilds it in the same sequence at weekly reset. `status` ∈ `complete` | `inprogress` | `notstarted` (legacy `incomplete` still normalized in the UI at `:2649`).

| # | `key` | Source | Progress | UI section |
|---|---|---|---|---|
| 1 | `weeklyMetaQuest` | `98172` (Trailing Xal'atath) | — | Weekly Quests |
| 2 | `curseSurges` | `96995` | count, required 3 | Weekly Quests |
| 3 | `purgingTheVaults` | `95520` | percent 0–100 | Weekly Quests |
| 4 | `saththerilSoiree` | `90575`, `90576`, `90574`, `90573` (any) | — | Weekly Events |
| 5 | `abundantOfferings` | `89507` | — | Weekly Events |
| 6 | `legendsOfTheHaranir` | `89268` | — | Weekly Events |
| 7 | `stormarianAssault` | `94581` | — | Weekly Events |
| 8 | `midnightWorldTour` | `95245` | count, required 4 | Weekly Events (`alwaysLast`) |
| 9 | `hiddenTrove` | spell `1248091` *Unlocking* (cast, not a quest) | — | Weekly Quests |
| 10 | `nightmarishTask` | `94446` | count, required 3 | Weekly Quests |
| 11 | `worldBoss` | `97128` (Lair: Nymrissa Wavecaller) | — | Weekly Quests |

Four collection quirks worth preserving in any rewrite:

- **`midnightWorldTour`** (`:1404-1433`) filters out the optional Lor'themar objective by normalizing objective text and string-matching `"lorthemar"`, and only reports a count when exactly 4 required objectives remain.
- **`worldBoss`** (`:1443-1456`) is **sticky**: a stored `complete` is preserved until reset, because the quest flag falls out of the API after login. Retired account-wide IDs kept in comments: `92034`, `92636`, `92560`, `92123`.
- **`purgingTheVaults`** uses `GetQuestProgressBarPercent`, falling back to objective ratio × 100.
- **`hiddenTrove`** (registration `:998`, dispatch `:1030-1034`, store and handler `:1193-1257`, read back at `:1596`) is **not read from a quest at all** — it is the only entry whose source is an event rather than the quest log. `UNIT_SPELLCAST_SUCCEEDED`, unit-filtered to `player`, matches `constants.HIDDEN_TROVE.SPELL_IDS` (`:119`, currently `1248091` *Unlocking* — the 1.5s Open Object cast) and writes `MyAltManagerDB.hiddenTrove[guid] = { completedAt, expires }`; `CollectData` reports `complete` while that record is live. The trove's quest ID is re-issued every season, the cast is not, which is why the quest ID (`86371` through Midnight S2) was dropped. Like `worldBoss` this makes the status **stored, not derived** — see the clean-slate cost table in §0.6.

#### PvP — `pvp`

| Field | Currency ID | Source | UI label |
|---|---|---|---|
| `pvp.honor` | `1792` | `quantity` | Honor |
| `pvp.conquest` | `1602` | `quantity` | Conquest |
| `pvp.conquestEarned` | `1602` | `totalEarned` | **Forged Weapons** |
| `pvp.bloodyTokens` | `2123` | `quantity` | Bloody Tokens |

#### Flat currencies — top level of `char_table`

Thirteen scalar fields sitting directly alongside structural fields, all `quantity` via `GetCurrencyAmount` (`:483`) unless noted.

| Field | Currency ID | Label | Displayed? |
|---|---|---|---|
| `undercoin` | `2803` | Undercoin | yes |
| `anglerPearls` | `3373` | Angler Pearls | yes |
| `voidlightMarl` | `3316` | Voidlight Marl | yes |
| `restored_coffer_keys` | `3028` | Bountiful Keys | yes |
| `cofferKeyShards` | `3310` | Coffer Key Shards | yes (needs a `dataKey` override) |
| `shardOfDundun` | `3376` | Shard of Dundun | yes |
| `remnantOfAnguish` | `3392` | Remnant of Anguish | yes |
| `unalloyedAbundance` | `3377` | Unalloyed Abundance | yes |
| `nebulousVoidcore` | `3418` ⚠️ **wrong for S2 — should be `3513`** | Nebulous Cores | **no** — has a label but no `constants.sections` child |
| `untaintedManaCrystal` | `3356` | Untainted Mana-Crystal | yes |
| `fieldAccolade` | `3405` | Field Accolade | yes |
| `luminousDust` | `3385` | Luminous Dust | yes |
| `brimmingArcana` | `3379` | Brimming Arcana | yes |

Plus `weeklyCofferKeysCollected` (number 0–4) — a count of completed quests among `84736`, `84737`, `84738`, `84739` (`:1458-1467`), zeroed at weekly reset.

> **Live bug — `nebulousVoidcore` is broken three ways.**
> 1. **Wrong currency ID for the active season.** `3418` is the Season 1 currency; Season 2's Nebulous Voidcore is **`3513`**. The addon has been polling a dead currency all season.
> 2. **Misfiled as season-agnostic.** It sits in `BASE_CURRENCIES` (`:359`), which `ApplyActiveSeasonData` merges *under* the season table (`:464`) — so a season override can never reach it. The ID belongs in `SEASON1_CURRENCIES` (`3418`) and `SEASON2_CURRENCIES` (`3513`), exactly like `catalyst` and the crests.
> 3. **No UI entry**, as noted above — it has a label but no `constants.sections.currencies.children` row, so even a correct value would never render.
>
> Corroborated in the live SavedVariables: all 13 characters store `nebulousVoidcore = 0`. Fixing the ID is a prerequisite for the website showing anything useful for this currency — and because the addon reads the ID live rather than storing it, **no historical data can be recovered**; correct values only start accruing after the fix ships and each character logs in.

`nebulousVoidcore` is also the only flat field that calls `GetRollingCurrencyValues` while keeping just the first return (`:1533`), so it stores a scalar like the others.

### 0.2 Account-wide state

| Table | Contents |
|---|---|
| `MyAltManagerDB.alts` | Denormalized character count, incremented in `StoreData` (`:1290`). |
| `MyAltManagerDB.meta` | `dataSchema`, `lastExpansionSeen` — drives `RunExpansionMigrationIfNeeded` (`:565-593`), which wipes `data` but preserves `config`. |
| `MyAltManagerDB.hiddenTrove` | Hidden Trove completions **keyed by character GUID** — `{ completedAt, expires }`, written from `UNIT_SPELLCAST_SUCCEEDED` (spell `1248091`) and pruned once `expires` passes by `ValidateReset` (`:1282-1290`). Deliberately outside `data`: `StoreData` replaces a character's whole table on every collect, and the trove is usually opened in combat or mid-delve where `CanCollectNow` (`:598-610`) blocks collection, so a flag written into `char_table` could be lost before it was ever stored. |
| `MyAltManagerDB.visibility` | ~43 booleans, a flat map mixing section keys (`currencies`, `pvp`, `great_vault`) and child keys (`myth_crests`, `world_boss`). Resolved by `IsRowVisible` (`:1089`) through `constants.section_lookup` / `child_lookup`. |
| `MyAltManagerDB.config` | Settings **and** transient UI state — see below. |

`config` keys (`InitDB` `:1065-1080`, plus two added at runtime):

`MIN_ITEM_LEVEL`, `MIN_LEVEL`, `sort`, `enable_drawer`, `drawer_config_version`, `frame_scale`, `openRows` (cleared on every load, `:763`), `framePoint` (`:2007`), `curse_surge_announce`, `curse_surge_announced_start_epoch`, `curse_surge_tracker_width` / `_height` / `_font_size` / `_background_opacity`, `curse_surge_tracker_point` (`:3517`), `curse_surge_tracker_shown_by_character` (**keyed by character GUID**).

### 0.3 Season-scoped constants (code, not saved data)

Changing season means editing code: `constants.ACTIVE_SEASON_ID` plus `constants.SEASON_DATA` (`:445-458`), which swaps `TIER_SETS`, `MAPS`, `currencies`, and the `tierLabel`. Tier set IDs: S1 `1978-1990`, S2 `2055-2067` (one per class, alphabetical by class). Curse Surge tracking (`constants.CURSE_SURGE`, `CURSE_SURGE_LOCATIONS`, `:100-131`) is a timing/announcement subsystem anchored to a hardcoded epoch — account state in `config`, never per-character data.

### 0.4 Not tracked at all

Confirmed absent from both the addon code and the live SavedVariables file — `UnitRace`, `UnitFactionGroup`, `GetSpecialization`, `GetProfessions`, `GetMoney`, `GetGuildInfo` return **zero** grep hits in `MyAltManager.lua`:

**race · faction · spec/specID/role · gold · professions · crafting concentration · guild · region · played time · renown/reputation · equipped items · bag or bank contents · achievements · raid lockouts · delve progress beyond the Hidden Trove opening · profession knowledge or weeklies**

### 0.5 Structural problems to fix in a rewrite

Ranked by how much pain each causes:

1. **Adding one currency touches five places** — `BASE_CURRENCIES` (`:347`), a local in `CollectData` (`:1525`), the `char_table` literal (`:1619`), `constants.sections.currencies.children` (`:225`), and `constants.labels` (`:157`). Miss the fourth and it silently stores but never displays, which is exactly what happened to `nebulousVoidcore`. A single declarative currency registry (id, key, label, icon, section, scalar-vs-rolling) would collapse all five.
2. **The stored value carries no record of which currency produced it.** `season.myth` means currency `3347` in S1 and `3446` in S2, with nothing in the record to say which. Store `currencyID` alongside the value. **This has already caused a live data-loss bug** — `nebulousVoidcore` has been reading the Season 1 ID (`3418`) instead of Season 2's (`3513`) for the whole season, and because the stored record keeps only a bare `0` with no ID, nothing in the data made the fault visible. A stored `currencyID` would have made it obvious on the first export.
3. **Flat currency fields pollute the record root.** Thirteen scalars sit as siblings of `vault`, `mplus`, and `schema`. They belong under a `currencies` sub-table.
4. **`weeklies` is a positional array that must stay in sync with `CreateResetWeeklies`.** Two hand-maintained ordered lists of 11 entries in different functions. Make it a keyed map and derive order from `constants.sections`.
5. **`season.*` are unlabeled 2-tuples** — `{0, 100}` with no field names, and `sparks` is season-agnostic while the underlying currency is not.
6. **Mixed naming conventions.** `restored_coffer_keys` and `coffer_key_shards` are snake_case while `cofferKeyShards` and `anglerPearls` are camelCase — the mismatch already forces a `dataKey` override at `:233`. Pick one.
7. **A schema bump is destructive.** `MigrateDataSchema` (`:543-563`) deletes rather than migrates, so improving the structure costs every user their history. Add real migration steps before restructuring anything.
8. **Presentation is stored as data.** `mplus.r/g/b` is a display colour; `tierSlots` holds localized display strings instead of slot IDs. Both should be derived at render.
9. **`config` mixes three concerns** — real settings, transient UI state (`openRows`, cleared at load), and per-character state keyed by GUID (`curse_surge_tracker_shown_by_character`). Split them. Per-character *progress* keyed by GUID now also lives at the root in `hiddenTrove`, outside both `config` and `data`, so the rewrite needs one clear home for character state that must survive a `StoreData` replacement.
10. **One timestamp per character.** `dataObtained` covers the whole record, so there is no way to know that vault data is fresh while concentration is a week old. Per-section timestamps would fix this.
11. **Identity is GUID-only.** No region, no normalized realm, no name-realm index — cross-account or cross-region merging is impossible as stored.
12. **`alts` is a denormalized count** that can drift from the real size of `data` (removal paths at `:1213`, `:1235` adjust it separately).

### 0.6 Proposed replacement data model

This is the rewrite target — a shape that works **as the in-game SavedVariables layout and as the export payload with almost no transformation**. Each design choice below maps to a numbered problem from §0.5.

Two governing principles:

- **Every stored value carries the ID that produced it.** Currencies store `currencyID`, weekly objectives store `questID` — or `spellID` where the source is a cast rather than a quest, as `hiddenTrove` now is — professions store `skillLineID`. This is what would have caught the `nebulousVoidcore` fault on the first export instead of after a full season. *(fixes #2)*
- **Declare once, derive everywhere.** Currencies and weekly objectives come from a registry in code; nothing is hand-listed a second time in the collector, the renderer, or the reset path. *(fixes #1, #4)*

#### Code-side registries (not saved data)

```lua
-- One declaration per currency. Season-varying IDs are keyed by seasonID;
-- season-agnostic currencies use a bare `id`. Adding a currency is ONE entry.
constants.CURRENCIES = {
    { key = "mythCrests",       label = "Myth Crests",       group = "crests",  mode = "rolling",
      ids = { [1] = 3347, [2] = 3446 } },
    { key = "sparks",           label = "Sparks",            group = "crests",  mode = "rolling",
      ids = { [1] = 3212, [2] = 3509 },  seasonLabel = { [1] = "Radiant Sparks", [2] = "Tidal Sparks" } },
    { key = "catalyst",         label = "Catalyst Charges",  group = "gear",    mode = "capped",
      ids = { [1] = 3378, [2] = 3465 } },
    { key = "nebulousVoidcore", label = "Nebulous Cores",    group = "tokens",  mode = "scalar",
      ids = { [1] = 3418, [2] = 3513 } },          -- the bug from §0.1, now unrepresentable
    { key = "honor",            label = "Honor",             group = "pvp",     mode = "scalar", id = 1792 },
    { key = "conquest",         label = "Conquest",          group = "pvp",     mode = "earned", id = 1602 },
    -- ...one row per currency, replacing BASE_/SEASON1_/SEASON2_CURRENCIES,
    --    constants.labels, and constants.sections.currencies.children
}

-- One declaration per weekly objective. Replaces the duplicated ordered lists in
-- CollectData (:1577) and CreateResetWeeklies (:1163).
constants.WEEKLIES = {
    { key = "weeklyMetaQuest",   label = "Weekly Meta Quest",     group = "quests", questIDs = { 98172 } },
    { key = "curseSurges",       label = "Turn Back the Surge",   group = "quests", questIDs = { 96995 },
      kind = "count",   required = 3 },
    { key = "purgingTheVaults",  label = "Purging the Vaults",    group = "quests", questIDs = { 95520 },
      kind = "percent" },
    { key = "saththerilSoiree",  label = "Sath'theril Soiree",    group = "events",
      questIDs = { 90575, 90576, 90574, 90573 } },
    { key = "midnightWorldTour", label = "Midnight: World Tour",  group = "events", questIDs = { 95245 },
      kind = "count",   required = 4, excludeObjective = "lorthemar", order = "last" },
    { key = "worldBoss",         label = "World Boss",            group = "quests", questIDs = { 97128 },
      sticky = true },   -- preserve a stored `complete` until reset (:1443)
    { key = "hiddenTrove",       label = "Hidden Trove (Delves)", group = "quests",
      source = "spellcast", spellIDs = { 1248091 },   -- UNIT_SPELLCAST_SUCCEEDED, not the quest log
      sticky = true },   -- nothing to re-derive at login; the cast is the only signal
    -- ...
}
```

`mode` drives collection: `scalar` = `quantity`; `rolling` = the `GetRollingCurrencyValues` pair (`:1469`); `capped` = `quantity` + `maxQuantity`; `earned` = `quantity` + `totalEarned`. `group` replaces the `constants.sections` children lists, so labels and visibility derive from one place. *(fixes #1, #6 — one naming convention, `camelCase`, enforced by the registry key)*

`source` on a weekly entry defaults to `"quest"` (read `questIDs` from the quest log at collect time). `"spellcast"` means the collector never polls: an event handler records the completion when one of `spellIDs` succeeds on the player, and collection only reads back what was recorded. Any `source = "spellcast"` entry is necessarily `sticky` — there is no API to re-derive it, so the stored record *is* the state.

#### Saved shape

```lua
MyAltManagerDB = {
    schemaVersion = 3,

    account = {
        region       = "US",              -- GetCurrentRegionName()
        label        = "FTORRES87",       -- user-set; WoW cannot read the WTF folder name
        settings     = { minLevel = 80, minItemLevel = 0, sort = "ilevel",
                         enableDrawer = true, frameScale = 1.10 },
        visibility   = { sections = { currencies = true, pvp = false },
                         entries  = { mythCrests = true, worldBoss = true } },
        ui           = { framePoint = { point, relativePoint, x, y },
                         curseSurge = { point = {...}, width = 380, height = 30,
                                        fontSize = 12, opacity = 85, announce = false,
                                        announcedStartEpoch = 0 } },
        uiByCharacter = { ["Player-3725-0A8145B7"] = { curseSurgeTrackerShown = true } },
    },                                    -- (fixes #9: settings / UI state / per-char UI state separated;
                                          --  #10: visibility split into sections vs entries)

    characters = {
        ["Player-3725-0A8145B7"] = {

            identity = {                                   -- (fixes #11)
                guid    = "Player-3725-0A8145B7",
                name    = "Faithqts",
                realm   = "Frostmourne",                   -- GetRealmName(), display form
                realmSlug = "Frostmourne",                 -- normalized: gsub("[%s'-]", "")
                realmID = 3725,                            -- parsed from the GUID
                region  = "US",
                class   = { token = "DRUID", id = 11 },
                race    = "NightElf",                      -- select(2, UnitRace("player"))
                faction = "Alliance",
                level   = 90,
                spec    = { id = 103, name = "Feral", role = "DAMAGER" },
                guild   = "Some Guild",
            },

            progression = {
                itemLevel = { equipped = 288, overall = 290 },   -- BOTH returns of GetAverageItemLevel()
                money     = 123456789,                            -- copper
                tier = {                                          -- (fixes #8: IDs, not display strings)
                    setID    = 2057,
                    count    = 2,
                    equipped = { [1] = 245678, [5] = 245680 },     -- invSlotID -> itemID
                    stored   = { 245681 },                         -- itemIDs found in bags
                },
                mplus = {                                         -- (fixes #8: no r/g/b)
                    score    = 3120,
                    keystone = { mapID = 507, level = 12 },        -- nil when none held
                    runs     = { },                                -- C_MythicPlus.GetRunHistory()
                },
            },

            vault = {                                    -- ordered 1..3 per track; genuinely positional
                raid    = { { threshold = 2, progress = 1, earned = false, activityID = 210, rewardItemLevel = nil }, ... },
                dungeon = { { threshold = 1, progress = 8, earned = true,  activityID = 213, rewardItemLevel = 720  }, ... },
                world   = { { threshold = 2, progress = 0, earned = false, activityID = 207, rewardItemLevel = nil }, ... },
            },

            weekly = {                                   -- (fixes #4: keyed map, order derived from registry)
                resetAt    = 1787065199,
                cofferKeys = { collected = 0, max = 4, questIDs = { 84736, 84737, 84738, 84739 } },
                objectives = {
                    curseSurges       = { questID = 96995, status = "inprogress",
                                          kind = "count",   progress = 1, required = 3 },
                    purgingTheVaults  = { questID = 95520, status = "inprogress",
                                          kind = "percent", progress = 42 },
                    worldBoss         = { questID = 97128, status = "complete", sticky = true },
                    weeklyMetaQuest   = { questID = 98172, status = "notstarted" },
                    hiddenTrove       = { spellID = 1248091, status = "complete", sticky = true,
                                          source = "spellcast", completedAt = 1786964336 },
                },
            },

            currencies = {                               -- (fixes #2, #3, #5: keyed, ID-tagged, named fields)
                mythCrests       = { id = 3446, quantity = 40,  earned = 140, max = 100, rollingMax = 100 },
                sparks           = { id = 3509, quantity = 0,   earned = 1,   rollingMax = 1 },
                catalyst         = { id = 3465, quantity = 0,   max = 8 },
                nebulousVoidcore = { id = 3513, quantity = 275 },
                honor            = { id = 1792, quantity = 0 },
                conquest         = { id = 1602, quantity = 0,   earned = 0 },
            },

            professions = {                              -- entirely new; see §1.3
                {
                    slot = 1, name = "Alchemy", baseSkillLineID = 171,
                    lines = {
                        { skillLineID = 2871, expansionName = "Khaz Algar",
                          skill = 100, maxSkill = 100,
                          concentration = { currencyID = 2807, quantity = 812, max = 1000,
                                            cycleMS = 360000, perCycle = 1, sampledAt = 1786964336 } },
                    },
                },
            },

            meta = {                                     -- (fixes #12: no denormalized count anywhere)
                schemaVersion = 3,
                addonVersion  = "13.0.0.1",
                seasonID      = 2,
                expansionID   = 12,
                lastSeen      = 1786964336,
                updated = {                              -- (fixes #7: per-section freshness)
                    identity = 1786964336, progression = 1786964336, vault = 1786964336,
                    weekly   = 1786964336, currencies  = 1786964336, professions = 1786901112,
                },
            },
        },
    },
}
```

#### What changes in behaviour

- **No storage gate.** `StoreData`'s level/ilvl filter (`:1262`, `:1282`) becomes a *display* filter reading `account.settings`. Every character that logs in is stored, which is what makes concentration tracking work for bank alts — and makes the separate `roster` table from §1.2 unnecessary. **If you take the rewrite path, build this instead of the roster split.**
- **No migration. Clean slate.** `MigrateDataSchema` (`:543-563`) and `RunExpansionMigrationIfNeeded` (`:565-593`) are both deleted. On first load, if `MyAltManagerDB.schemaVersion ~= 3`, discard the entire table and re-init. Each character repopulates on its next login. `constants.DATA_SCHEMA`, `meta.dataSchema`, and `meta.lastExpansionSeen` all go away — `schemaVersion` at the root is the only version gate.
- **`alts` disappears.** Count `characters` when needed.

#### What a clean slate actually costs

Almost nothing, because nearly every field is re-derivable from a live API on next login rather than accumulated over time:

| Recovers fully on login | Why |
|---|---|
| Vault progress (all three tracks) | `C_WeeklyRewards.GetActivities()` returns current-week state |
| All currencies | `C_CurrencyInfo.GetCurrencyInfo()` is authoritative |
| Weekly quest status | `C_QuestLog.IsQuestFlaggedCompleted()` / `IsOnQuest()` hold for the current week — **except `hiddenTrove`, see below** |
| M+ score, keystone, run history | `C_ChallengeMode` / `C_MythicPlus` are live |
| Tier, catalyst, item level, identity | All read from the character directly |
| Professions and concentration | Live from `C_TradeSkillUI` / `C_CurrencyInfo` |

The genuine losses are the two **sticky** entries, `worldBoss` and `hiddenTrove`:

- **`worldBoss`** is sticky because the quest flag falls out of the API after login (`:1443-1451`), so a character that killed the world boss earlier in the week and is wiped mid-week may read `notstarted` until the next reset.
- **`hiddenTrove`** is sticky because its only signal is the `UNIT_SPELLCAST_SUCCEEDED` cast, which fires once and cannot be queried afterwards. Wiping `MyAltManagerDB.hiddenTrove` mid-week loses that week's completions outright, and no login re-derives them. **Whatever else the rewrite discards, carry this table across verbatim** — it is small, keyed by GUID, and self-expiring, so preserving it costs nothing.

Both self-correct at the next reset.

**Ship the rewrite immediately after a weekly reset** and even that loss is zero. The other cost is purely operational: characters are absent from the addon and the website until each one logs in once — with 13 alts that's one sweep.

#### Export envelope

The export is the saved shape plus a thin envelope — no restructuring step, so the two can never drift:

```jsonc
{
  "format": "MAM",
  "formatVersion": 2,
  "schemaVersion": 3,
  "addonVersion": "13.0.0.1",
  "exportedAt": 1786964336,
  "exportedBy": "Player-3725-0A8145B7",
  "account": { /* verbatim, minus `ui` and `uiByCharacter` — not useful to the website */ },
  "characters": { /* verbatim */ },
  "catalog": {
    "currencies": {
      "mythCrests":       { "label": "Myth Crests",   "group": "crests", "id": 3446, "iconFileID": 5872031 },
      "nebulousVoidcore": { "label": "Nebulous Cores","group": "tokens", "id": 3513, "iconFileID": 5931199 }
    },
    "weekly": {
      "curseSurges": { "label": "Turn Back the Surge", "group": "quests", "questIDs": [96995] },
      "hiddenTrove": { "label": "Hidden Trove (Delves)", "group": "quests", "source": "spellcast",
                       "spellIDs": [1248091] }
    }
  }
}
```

**`catalog` is the payoff.** It is the registry serialized at export time, so the website renders labels and grouping from the payload rather than a hardcoded copy. A new currency, a new weekly, or a whole new season then needs an addon change only — the website picks it up with no frontend deploy and no schema bump. Without it, every one of §0.1's tables has to be duplicated in TypeScript and kept in sync by hand.

`iconFileID` is a Blizzard file ID, not a URL — the website can either ignore it, map it through a community CDN, or fall back to text labels. Treat it as optional.

---

## Part 1 — Addon changes (`C:\git\MyAltManager`)

> **The chosen path is the §0.6 ground-up rewrite** — new data model, no migration, clean slate, characters repopulate on next login. That supersedes parts of this section:
>
> | Section | Status under the rewrite |
> |---|---|
> | §1.1 New files and TOC | **Applies**, with `MyAltManager.lua` itself being rewritten rather than edited |
> | §1.2 Unfiltered roster table | **Superseded** — §0.6 has one `characters` table with no storage gate, so there is nothing to split |
> | §1.3 Profession + concentration collection | **Applies** — the collector is unchanged; it writes into `characters[guid].professions` |
> | §1.4 Serialization | **Applies** unchanged |
> | §1.5 Export payload schema | **Superseded** by the §0.6 envelope (`formatVersion: 2`, with `catalog`) |
> | §1.6 Export UI | **Applies** unchanged |
> | §1.7 Nebulous Voidcore fix | **Moot** — the `constants.CURRENCIES` registry makes the bug unrepresentable |
> | §1.8 Release chores | **Applies** unchanged |
>
> Every "do not bump `DATA_SCHEMA`" warning below is void: there is no `DATA_SCHEMA`, and the root `schemaVersion` gate wipes deliberately.

### 1.1 New files and TOC

`MyAltManager.lua` is already 3661 lines; this adds ~600 more. Split it:

```
libs/LibStub/LibStub.lua
libs/LibDeflate/LibDeflate.lua
MyAltManager.lua                 (existing — small edits only)
MyAltManager_Roster.lua          (new: roster + professions + concentration)
MyAltManager_Export.lua          (new: JSON, base64, payload builder, export dialog)
```

`MyAltManager.toc` load order — libs first, `MyAltManager.lua` next (it owns `constants` and the `AltManager` table), then the new files:

```
libs\LibStub\LibStub.lua
libs\LibDeflate\LibDeflate.lua
MyAltManager.lua
MyAltManager_Roster.lua
MyAltManager_Export.lua
```

The new files access shared state via `local _, AltManager = ...` and `AltManager.constants` (exposed at `MyAltManager.lua:19`). They must define functions only — no work at load time; entry points are called from the existing event dispatcher.

Use **lowercase `libs/`** — `AGENTS.md:6` and `.github/workflows/release.yml:101` (`--include '/libs/***'`) both assume lowercase, and packaging runs on Linux where case matters. Per `.github/agents/wow-addon.agent.md`, introducing LibDeflate also warrants a `lib-libdeflate` skill doc under `.github/skills/`.

### 1.2 Unfiltered roster — `MyAltManager_Roster.lua`

New account-wide table, initialised alongside the others in `AltManager:InitDB()` (`MyAltManager.lua:1061-1087`):

```lua
MyAltManagerDB.roster = {}   -- [guid] = roster_entry, NO level/ilvl gate
```

`AltManager:CollectRoster()` writes the current character unconditionally:

```lua
roster[guid] = {
    guid, name, realm, realmSlug,        -- realmSlug = realm:gsub("[%s'-]", "")
    region,                               -- GetCurrentRegionName() or GetCurrentRegion()
    class, classID,                       -- select(2,UnitClass), select(3,UnitClass)
    race,                                 -- select(2, UnitRace("player"))  (english token)
    faction,                              -- UnitFactionGroup("player")
    level        = UnitLevel("player"),
    ilevel       = math.floor(select(2, GetAverageItemLevel()) or 0),
    specID, specName, role,               -- C_SpecializationInfo.GetSpecialization() + GetSpecializationInfo()
    gold         = GetMoney(),            -- copper
    guild        = GetGuildInfo("player"),
    lastSeen     = time(),                -- UTC epoch, same clock as data[*].dataObtained
    professions  = AltManager:CollectProfessions(),
}
```

None of this touches `StoreData`, `CollectData`, or `constants.DATA_SCHEMA`.

> **Do not bump `constants.DATA_SCHEMA` (`MyAltManager.lua:20`).** `AltManager:MigrateDataSchema()` (`:543-563`) *deletes* every record whose `schema < 2`. A bump would wipe all 13 existing characters. The roster is an additive, independently-keyed table specifically so no bump is needed.

### 1.3 Profession + concentration collection

```lua
function AltManager:CollectProfessions()
    local out = {}
    local prof1, prof2 = GetProfessions()          -- slots 3-5 (cooking/fishing/arch) have no concentration
    for slot, index in ipairs({ prof1, prof2 }) do
        if index then
            local name, _, skillLevel, maxSkill, _, _, baseSkillLineID = GetProfessionInfo(index)
            local entry = { slot = slot, name = name, baseSkillLineID = baseSkillLineID, lines = {} }

            for _, skillLineID in ipairs(C_TradeSkillUI.GetAllProfessionTradeSkillLines() or {}) do
                local info = C_TradeSkillUI.GetProfessionInfoBySkillLineID(skillLineID)
                local belongs = info and (skillLineID == baseSkillLineID
                                          or info.parentProfessionID == baseSkillLineID)
                if belongs then
                    local currencyID = C_TradeSkillUI.GetConcentrationCurrencyID(skillLineID)
                    local ci = currencyID and currencyID ~= 0
                               and C_CurrencyInfo.GetCurrencyInfo(currencyID) or nil
                    if ci and ci.discovered then
                        entry.lines[#entry.lines + 1] = {
                            skillLineID   = skillLineID,
                            expansionName = info.expansionName,
                            skillLevel    = info.skillLevel,
                            maxSkillLevel = info.maxSkillLevel,
                            concentration = {
                                currencyID      = currencyID,
                                quantity        = ci.quantity,
                                max             = ci.maxQuantity,
                                cycleMS         = ci.rechargingCycleDurationMS,
                                amountPerCycle  = ci.rechargingAmountPerCycle,
                                sampledAt       = time(),
                            },
                        }
                    end
                end
            end
            out[#out + 1] = entry
        end
    end
    return out
end
```

**Store every expansion line that has a discovered concentration currency**, not just the newest. The website decides which to surface; a stored array survives the next expansion without an addon change.

**Timing.** Profession and currency data are not warm at `PLAYER_LOGIN` — `FaithsCraftAssist.lua:968-971` re-runs its refresh one second later for exactly this reason. Hook `CollectRoster` into the existing dispatcher (`MyAltManager.lua:993-1048`) on:

- `PLAYER_LOGIN`, plus a `C_Timer.After(2, ...)` second pass
- `SKILL_LINES_CHANGED` (register it — not currently registered)
- `PLAYER_EQUIPMENT_CHANGED`, `CURRENCY_DISPLAY_UPDATE` (both already registered at `:982-990`)

Throttle with the same pattern as `AltManager:ScheduleCollect` (`:635-663`) — a stored `_rosterTimer` plus a minimum interval. Wrap the collector in `pcall` the way `CollectAndStore` (`:622`) does. **No `OnUpdate`** — `events.md` forbids it; `C_Timer` only.

Note that `CanCollectNow()` (`:599`) blocks in combat and during M+; roster collection is cheap and read-only, so it only needs `IsLoggedIn()`. Don't reuse the full gate or bank alts logging in mid-combat get skipped.

### 1.4 Serialization — `MyAltManager_Export.lua`

**JSON encoder** (~80 lines). The one real hazard is **empty-table ambiguity**: `tierSlots = {}` and `runHistory = {}` are empty on all 13 current characters, and Lua cannot distinguish `[]` from `{}`. Keep an explicit array-key set so encoding is deterministic:

```lua
local ARRAY_KEYS = {
    runHistory = true, weeklies = true, raid = true, dungeon = true, world = true,
    sparks = true, adventurer = true, veteran = true, champion = true, hero = true,
    myth = true, tierSlots = true, professions = true, lines = true,
}
```

Also: escape `"`, `\` and all bytes `< 0x20`; pass UTF-8 through unescaped; format integral numbers with `%d` (avoid `1.0`); reject `nan`/`inf`; build with `table.concat`, never `..` in a loop.

**Base64 encoder** (~30 lines). Standard RFC 4648 alphabet with `=` padding so the browser's `atob` works directly. **Do not use `LibDeflate:EncodeForPrint`** — that is a WoW-specific alphabet no JS decoder understands.

**Pipeline:**

```lua
local json     = AltManager:EncodeJSON(payload)
local deflated = LibDeflate:CompressZlib(json)          -- zlib wrapper → adler32 integrity check
local encoded  = AltManager:EncodeBase64(deflated)
return "MAM1:" .. encoded
```

`CompressZlib` (not `CompressDeflate`) so the browser side uses `pako.inflate` and gets a free checksum. Expect ~42 KB of Lua → ~35 KB JSON → **5–8 KB** of base64 — one comfortable clipboard line.

### 1.5 Export payload schema v1

```jsonc
{
  "format": "MAM",
  "formatVersion": 1,
  "addonVersion": "12.1.0.44",
  "dataSchema": 2,
  "seasonID": 2,
  "region": "US",
  "exportedAt": 1786964336,          // time() — UTC epoch seconds
  "exportedBy": { "guid": "Player-3725-0A8145B7", "name": "Faithqts", "realm": "Frostmourne" },
  "weeklyResetAt": 1787065199,       // AltManager:GetNextWeeklyResetTime()  (:3657)
  "settings": { "visibility": { }, "sort": "ilevel" },
  "characters": {
    "Player-3725-0A8145B7": {
      "guid": "...", "name": "Faithqts", "realm": "Frostmourne", "realmSlug": "Frostmourne",
      "class": "DRUID", "classID": 11, "race": "NightElf", "faction": "Alliance",
      "level": 90, "ilevel": 288,
      "specID": 103, "specName": "Feral", "role": "DAMAGER",
      "gold": 123456789, "guild": "Some Guild",
      "lastSeen": 1786964336,
      "tracked": true,                 // false = roster-only, `progress` absent
      "professions": [
        {
          "slot": 1, "name": "Alchemy", "baseSkillLineID": 171,
          "lines": [{
            "skillLineID": 2871, "expansionName": "Khaz Algar",
            "skillLevel": 100, "maxSkillLevel": 100,
            "concentration": {
              "currencyID": 2807, "quantity": 812, "max": 1000,
              "cycleMS": 360000, "amountPerCycle": 1, "sampledAt": 1786964336
            }
          }]
        }
      ],
      "progress": { /* the existing char_table from MyAltManager.lua:1548-1637,
                       minus identity fields already hoisted above:
                       tierPieces, tierSlots, catalyst, mplus, vault, season,
                       weeklies, pvp, runHistory, all flat currencies,
                       weeklyCofferKeysCollected, expires, dataObtained */ }
    }
  }
}
```

Built by joining `MyAltManagerDB.roster` (all characters) with `MyAltManagerDB.data` (tracked characters) on GUID. `tracked` is `true` when a `data[guid]` record exists.

`MyAltManagerDB.hiddenTrove` needs no envelope entry of its own — its state is already baked into each character's `progress.weeklies` as the `hiddenTrove` status by the time the record is stored. It only has to survive *locally*; see §0.6's clean-slate costs.

Include `nebulousVoidcore` — it is collected and stored (`:1533`, `:1627`) but has no entry in `constants.sections.currencies.children`, so the in-game UI never shows it. The website should.

### 1.6 Export UI

- **Button:** in `AltManager:InitializeFrame()` right after `MyAltManager.lua:1995`, built with the existing `CreateFlatButton(parent, label)` factory (`:1836-1871`) — it already supplies the addon's flat gold/dark styling, hover, pushed state and inset border. Anchor `"RIGHT", frame.closeButton, "LEFT", -4, 0` and `:SetSize(54, 18)`.
- **Dialog:** `MyAltManagerExportFrame`, modelled on `AltManager:InitializeCurseSurgeTracker()` (`:3461-3553`) — a `UIParent`-parented movable frame. Reuse `CreateInsetBorder` (`:1814`), `CreateText` (`:1768`), `SetFontColor` (`:1756`), `SetGradientTexture` (`:1806`). Contents: title, a `ScrollFrame` wrapping a multi-line `EditBox` with `SetMaxBytes(0)`, `SetAutoFocus(true)`, `OnEscapePressed` → `Hide`, and a "Press Ctrl+C to copy" hint. Call `HighlightText()` inside `C_Timer.After(0, ...)` — highlighting in the same frame as `SetText` is unreliable.
- **Slash:** add `export` to `SlashCmdList.ALTMANAGER` (`:938-962`) and to its `help` output.
- Colours come only from `constants.colors` — `events.md` forbids new hex values in the render path.

### 1.7 Pre-existing bug to fix alongside

Independent of the export work, but it should ship in the same pass since the website will surface the field:

**Nebulous Voidcore reads the wrong currency.** Move `nebulousVoidcore` out of `BASE_CURRENCIES` (`:359`) and into the season tables — `SEASON1_CURRENCIES.nebulousVoidcore = 3418`, `SEASON2_CURRENCIES.nebulousVoidcore = 3513` — so `ApplyActiveSeasonData` (`:460-467`) picks the right one. Then add the missing `constants.sections.currencies.children` entry (`:225-244`) and its `keys` list entry (`:224`) so it renders in-game, and a `visibility` default. No `DATA_SCHEMA` bump — the field name is unchanged, values simply start reading correctly on the next collection.

### 1.8 Release chores (mandatory per repo convention)

- Bump `## Version:` in `MyAltManager.toc` — `.github/copilot-instructions.md` makes this the release trigger; no bump means no release.
- Add a `## <version> — <YYYY-MM-DD>` stanza to `CHANGELOG.md`, newest first, plain past-tense bullets.
- Deploy to `D:\World of Warcraft\_retail_\Interface\AddOns\MyAltManager` per `AGENTS.md:5-8` — copy `MyAltManager.lua`, the two new `.lua` files, `MyAltManager.toc`, `libs`, `media`, plus changed `README.md`/`CHANGELOG.md`. Never mirror-delete; preserve the destination `.git`.
- No `Co-Authored-By` or AI-attribution trailers (`AGENTS.md:12`).
- Log any mistakes to `MISTAKES.md` before handing back (`AGENTS.md:16-19`).

---

## Part 2 — Website (`C:\git\MyAltManagerWeb`, new repo)

A **separate repository**. Portainer GitOps polls one repo for one `docker-compose.yml`; mixing a Node app into the addon repo entangles the addon's tag-driven release pipeline with web deploys and risks the packaging step. The coupling between them is a single versioned schema (`formatVersion`), documented in both repos.

### 2.1 Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Vue 3, `<script setup>`, TypeScript | |
| Build | Vite | |
| State | Pinia | Hand-rolled `localStorage` persistence — the merge logic is custom, so a persistence plugin gets in the way |
| Routing | Vue Router, history mode | Server SPA fallback handles deep links |
| Styling | Tailwind CSS v4 | Class colours and status chips are utility-shaped work |
| Validation | Zod | The import string is untrusted user input — validate before it reaches the store |
| Decompression | `pako` | `inflate` matches `LibDeflate:CompressZlib` |
| Tests | Vitest | Decode, merge, and projection are pure functions and fully unit-testable |
| Server | Node 22 + Express | Static + SPA fallback + `/healthz` |
| Database | **none** | |

### 2.2 Layout

```
src/
  lib/
    schema.ts          Zod schemas + inferred TS types for payload v1
    importString.ts    decodeExport(): prefix check → atob → pako.inflate → TextDecoder → JSON → zod
    merge.ts           mergeSnapshot(existing, incoming)
    concentration.ts   projectConcentration(entry, now)
    wow.ts             class colours, spec names, currency labels, formatters
  stores/alts.ts       Pinia store; hydrate on init, persist on mutate
  composables/
    usePasteImport.ts  document-level paste listener
    useToast.ts
  views/
    RosterView.vue  ConcentrationView.vue  VaultView.vue
    WeekliesView.vue  CurrenciesView.vue  DataView.vue
  components/         CharacterRow, ConcentrationCard, VaultGrid, StatusChip, ImportBox, EmptyState
server/index.js
Dockerfile  docker-compose.yml  .dockerignore
```

### 2.3 Paste-anywhere import

`usePasteImport` registers a `paste` listener on `document`:

1. Bail if `event.target` is an `input`, `textarea`, or `[contenteditable]` — otherwise the manual paste box double-fires.
2. Read `event.clipboardData.getData('text')`, trim.
3. Match `/^MAM\d+:[A-Za-z0-9+/=\s]+$/`. If it doesn't match, ignore silently — the user was pasting something else.
4. `decodeExport()` → on success `store.import(payload)` and toast "Imported 14 characters"; on failure toast the specific reason (bad prefix / unsupported `formatVersion` / corrupt / schema mismatch).

Because a bare paste listener is unreliable on mobile and in some browser contexts, `DataView` also carries a visible textarea plus a "Read clipboard" button using `navigator.clipboard.readText()`. Both funnel into the same `store.import`.

### 2.4 Persistence and merge

localStorage keys:

| Key | Contents |
|---|---|
| `mam.snapshot.v1` | The merged payload |
| `mam.prefs.v1` | Sort, column visibility, theme |

`mergeSnapshot` reconciles the two decisions above — replace at the account level, merge at the character level:

- Account-level fields (`exportedAt`, `settings`, `addonVersion`, `seasonID`, `weeklyResetAt`) — take the incoming values when `incoming.exportedAt >= existing.exportedAt`.
- `characters` — per GUID, keep the incoming record only when `incoming.lastSeen > existing.lastSeen`. A stale export never overwrites a fresher alt.
- Characters absent from the incoming export are **kept**, flagged stale in the UI. `DataView` offers "Prune characters not in the last export" and per-character delete.
- Reject outright if `formatVersion` is newer than the app understands, with a "update the website" message.

### 2.5 Concentration projection

```ts
export function projectConcentration(c: Concentration, now = Date.now()) {
  const elapsedMs = Math.max(0, now - c.sampledAt * 1000);
  const gained    = Math.floor(elapsedMs / c.cycleMS) * c.amountPerCycle;
  const current   = Math.min(c.max, c.quantity + gained);
  const remaining = c.max - current;
  const msToCap   = remaining > 0 ? Math.ceil(remaining / c.amountPerCycle) * c.cycleMS : 0;
  return { current, max: c.max, pct: current / c.max, isCapped: remaining === 0,
           capsAt: now + msToCap, msToCap };
}
```

Recomputed against a `now` ref that ticks every 30s so the page stays live. Status thresholds: `< 75%` neutral, `75–99%` warning, `100%` red "capped — wasting regen". Note the projection is a lower bound if you crafted since the snapshot; label every card with "as of <relative time>".

### 2.6 Views

| View | Content |
|---|---|
| **Roster** (default) | Sortable table of every character. Tracked characters show ilvl / M+ / vault / crests; roster-only characters are dimmed with a "no progress data" badge. Class-coloured names. |
| **Concentration** | The headline view. One card per character × profession line: projected bar, current/max, time-to-cap, last-seen age. Default sort = most urgent first (capped, then nearest to cap). Covers untracked characters — the whole reason for the roster table. |
| **Great Vault** | 3×3 grid per character, earned slots showing reward ilvl. |
| **Weeklies** | Character × 11-quest matrix of status chips, driven by the `weeklies` array key order. |
| **Currencies** | Character × currency matrix with account totals, including `nebulousVoidcore`. |
| **Data** | Snapshot age, import box, character list with delete, prune, download snapshot as `.json`, clear all. |

Labels and grouping mirror `constants.sections` from the addon (`MyAltManager.lua:186-246`) so both surfaces stay consistent — port it once into `src/lib/wow.ts` rather than scattering literals through components.

---

## Part 3 — Deployment

### 3.1 Server (`server/index.js`)

Express: `compression()`, `express.static('dist', { maxAge: '1y', index: false })` with `index.html` served `no-cache`, SPA fallback to `index.html`, `GET /healthz` → `200 {"ok":true}`, `app.set('trust proxy', 1)` for Cloudflare, `PORT` env (default 8080). No auth, no API, no session — Cloudflare Zero Trust is the only gate.

### 3.2 Dockerfile

Multi-stage: `node:22-alpine` build stage (`npm ci` → `npm run build`) → `node:22-alpine` runtime with `npm ci --omit=dev`, `dist/` and `server/` copied in, `USER node`, `EXPOSE 8080`, `HEALTHCHECK` hitting `/healthz`. Final image lands around 150 MB.

### 3.3 CI → GHCR

`.github/workflows/docker.yml` on push to `main` and on tags: `docker/build-push-action` with buildx + layer cache, pushing `ghcr.io/<owner>/myaltmanager-web:latest` and `:${{ github.sha }}`.

Building in CI rather than on the Docker host keeps builds off the host and makes Portainer redeploys a fast `pull`.

### 3.4 Portainer GitOps

`docker-compose.yml` at the repo root:

```yaml
services:
  myaltmanager-web:
    image: ghcr.io/<owner>/myaltmanager-web:latest
    container_name: myaltmanager-web
    restart: unless-stopped
    ports:
      - "8087:8080"
    environment:
      NODE_ENV: production
      PORT: "8080"
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://127.0.0.1:8080/healthz"]
      interval: 30s
      timeout: 5s
      retries: 3
```

Portainer → Stacks → Add stack → **Repository**, point at the GitHub repo, enable GitOps updates with either 5-minute polling or the webhook (webhook is better: add it as a repository webhook so a merge deploys immediately). Enable "Re-pull image" so `:latest` actually moves.

If the GHCR package is private, add a registry credential in Portainer with a GitHub PAT scoped to `read:packages`. Making the package public avoids that entirely and leaks nothing — the image contains no data.

### 3.5 Cloudflare

Already configured — add a public hostname on the existing tunnel pointing at `http://<docker-host>:8087`. Nothing in the app needs to change: the Vite base stays `/`, all asset URLs are relative, and `trust proxy` makes `X-Forwarded-*` behave. Zero Trust supplies the only authentication; since all data lives in the visitor's own `localStorage`, there is no server-side state to protect.

---

## Build order

| Phase | Deliverable |
|---|---|
| 0 | Back up the current SavedVariables file. Commit §0.6 to both repos as the schema contract. |
| 1 | Addon rewrite: `constants.CURRENCIES` / `constants.WEEKLIES` registries, the new `characters` model, `schemaVersion` clean-slate reset, collectors for identity / progression / vault / weekly / currencies. Verify in-game via `/dump MyAltManagerDB.characters`. |
| 1b | Addon: profession + concentration collection (§1.3) writing into `characters[guid].professions`. |
| 2 | Addon: `MyAltManager_Export.lua` — JSON, base64, envelope + `catalog`, dialog, `/alts export`. Capture a real export string as a test fixture. |
| 3 | Web: scaffold, `schema.ts`, `importString.ts`, `merge.ts`, `concentration.ts`, store, paste handler, `DataView`. Round-trip the Phase 2 fixture. |
| 4 | Web: Roster, Concentration, Vault, Weeklies, Currencies views. |
| 5 | Dockerfile, compose, GH Actions, Portainer stack, Cloudflare hostname. |

Phase 3 is testable against the real fixture without any of Phase 4, so the risky part (encode/decode round-trip) is proven before any UI work.

---

## Verification

**Addon**
1. `/console scriptErrors 1`, then `/reload`. No Lua errors.
2. `/dump MyAltManagerDB.characters` — confirm an entry for the current character with populated `identity`, `currencies` (each carrying its `id`), and `professions[].lines[].concentration`.
2b. Cross-check the new collector against the **backed-up old SavedVariables**: currencies, vault progress and weekly statuses should match for any character that has not played since the backup. This is the main safety net a clean slate gives up, so use it.
3. Open the profession window; the exported `quantity` / `max` must match the number Blizzard shows in `ProfessionsCurrencyWithLabelMixin` (bottom-left of the crafting page). `/dump C_CurrencyInfo.GetCurrencyInfo(<currencyID>)` to cross-check.
4. **Log in on a level-20 bank alt with a profession, `/reload`, and confirm it is stored with its concentration.** The old build would have rejected it at the level/ilvl gate; the rewrite stores every character and filters only at display time. Then set a display minimum in settings and confirm it disappears from the in-game list while remaining in `MyAltManagerDB.characters`.
5. `/alts export` — the dialog opens, the string starts `MAM1:`, is one line, and is under ~10 KB. Ctrl+C works.
6. Log out fully (SavedVariables only flush on logout/reload), reopen `MyAltManager.lua` in `WTF\Account\FTORRES87\SavedVariables\`, and confirm `roster` persisted.

**Website**
1. `npm run test` — unit tests for `decodeExport` (valid fixture, bad prefix, corrupt base64, future `formatVersion`), `mergeSnapshot` (stale export does not clobber a newer character), `projectConcentration` (fixed `now`, mid-fill, exact cap, past cap).
2. `npm run dev`, paste the fixture anywhere on the page — toast fires, roster renders all characters, untracked ones show the badge.
3. Paste an intentionally older export — DevTools → Application → Local Storage shows the newer characters preserved.
4. Hard refresh — data persists.
5. Concentration view against a known character: projected value should exceed the snapshot value by roughly `elapsed / cycleMS`, and match in-game after logging that character in.

**Deployment**
1. `docker build -t mam-web . && docker run --rm -p 8087:8080 mam-web`; `curl localhost:8087/healthz` → 200; load the root; deep-link `/concentration` and confirm the SPA fallback works.
2. Push to `main`, confirm the GHCR image publishes, trigger the Portainer GitOps update, confirm the container is healthy.
3. Hit the Cloudflare hostname, pass Zero Trust, paste an export, confirm end-to-end.

---

## Risks and gotchas

- **SavedVariables freshness.** The export is built from live memory, so it's current for the logged-in character — but every other alt is only as fresh as its last login. The website must show a per-character "last seen" age prominently, or the concentration numbers will mislead.
- **Empty-table JSON ambiguity.** `tierSlots` and `runHistory` are `{}` on all 13 current characters. Without the explicit `ARRAY_KEYS` set they encode as `{}` and break the Zod array schemas. Cover this with a unit test on the encoder output.
- **Cold profession data at login.** `skillLevel` can read 0 and `discovered` can be false immediately after `PLAYER_LOGIN`. The 2-second delayed second pass plus `SKILL_LINES_CHANGED` handles it; without them, bank alts export with empty `professions`.
- **The clean slate is one-way.** The `schemaVersion ~= 3` check wipes `MyAltManagerDB` with no backup. Take a copy of `WTF\Account\FTORRES87\SavedVariables\MyAltManager.lua` before the first launch of the rewrite — it is the only record of the old data, and it doubles as a fixture for testing the new collector against known-good values.
- **Characters are invisible until they log in.** Both the addon and the website show an empty or partial roster until each alt has been through one login. Expect a full sweep before the site is useful, and ship right after a weekly reset so no `worldBoss` state is lost.
- **`realmName` is unnormalized** (`:1556`, raw `GetRealmName()` with spaces and apostrophes). Derive `realmSlug` in the addon; don't make the website guess.
- **`GetProfessions()` returns five slots.** Only 1 and 2 are primary and carry concentration; 3–5 (archaeology, fishing, cooking) do not. Taking `ipairs({prof1, prof2})` stops at the first `nil`, so a character with only a second profession would be missed — index explicitly rather than relying on `ipairs`.
- **Untrusted input.** The paste handler runs on arbitrary clipboard content. Zod validation before anything reaches the store is not optional; render text only, never `v-html`.
- **`:latest` and Portainer.** Without "Re-pull image" enabled, GitOps updates the compose file but keeps the cached image. Enable it, or pin `:${sha}` and let CI rewrite the compose file.
