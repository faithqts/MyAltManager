# MyAltManager Patch Notes

This file records the user-facing changes for each version represented in the repository. Older entries are reconstructed from the corresponding tagged or versioned commits.

## 12.1.0.19 — 2026-08-13

- Added a standalone Curse Surge progress bar, toggled by clicking the Curse Surge footer in MyAltManager.
- Added `MM:SS` countdowns for both the wait until the next surge and the five-minute active period.
- Added phase-based progress fill, matte dark-green styling, high-contrast white text, and a dark-grey background.
- Made the tracker draggable and persistent when the main MyAltManager window is closed or the UI is reloaded.
- Added Interface settings for tracker width, height, text size, and background opacity.

## 12.1.0.18 — 2026-08-13

- Replaced the rotating weekly meta-quest list with the single Season 2 quest `Trailing Xal'atath` (quest ID `98172`).
- Kept `Turn Back the Surge` (quest ID `96995`) separately tracked as `Curse Surges`.

## 12.1.0.17 — 2026-08-12

- Changed `/alts` so every character information drawer starts collapsed whenever the dashboard is opened.
- Made drawer expansion temporary UI state instead of restoring an expanded character on the next opening.

## 12.1.0.16 — 2026-08-12

- Fixed the minimum item-level setting so previously stored characters below the threshold are hidden from the dashboard.
- Applied the same reversible filtering behavior to the minimum character-level setting.
- Made both filters refresh the visible dashboard immediately without deleting stored character data.

## 12.1.0.15 — 2026-08-12

- Updated the addon for Patch 12.1 and Midnight Season 2 (`Interface 120100`).
- Activated the Season 2 tier-set IDs and catalyst currency, preventing Season 1 tier pieces from being counted.
- Replaced Radiant Sparks with Tidal Sparks (currency ID `3509`) and updated Season 2 crest currencies.
- Added Season 2 challenge maps for Altar of Fangs, Murder Row, Den of Nalorakk, Voidscar Arena, and The Blinding Vale.
- Rebuilt the dashboard into compact Character, Mythic+, Great Vault, and Currency columns with progress bars and expandable weekly-detail drawers.
- Added a data-schema migration so incompatible saved character records are safely discarded.
- Added modern Interface settings for minimum levels and parent/child section visibility.
- Added the Curse Surge footer schedule with the poison-buff icon, local-time next occurrence, and a green five-minute active state.
- Added `Curse Surges` weekly quest tracking for quest ID `96995`.
- Moved the version to the center of the footer, retained weekly-reset information on the right, and increased header/footer text contrast.
- Removed Curse Surge calendar-opening behavior and tooltips.

## 12.0.7.0 — 2026-07-08

- Updated the Retail client Interface target from `120005` to `120007`.
- Bumped release metadata for the corresponding Midnight client build.

## 12.0.5.3 — 2026-07-08

- Added season-aware configuration for currencies, tier sets, and Mythic+ map pools.
- Hardened data collection with guarded error handling, collection throttling, and refresh events for equipment, weekly rewards, and Mythic+ metadata.
- Reworked Great Vault collection around current Blizzard activity enums and example reward item levels.
- Added asynchronous tier-item rescans so uncached equipped or bag items are counted after their data loads.
- Preserved weekly world-boss completion until reset and corrected raid/delve fallback thresholds.
- Added addon-compartment support and removed unused LibStub, embedded XML, sounds, and media.

## 12.0.5.2 — 2026-05-09

- Replaced custom Escape-key interception with Blizzard's `UISpecialFrames` handling.
- Fixed protected-action errors caused by changing keyboard-input propagation while closing the window.

## 12.0.5.1 — 2026-05-08

- Added automated GitHub packaging, version tags, release notes, downloadable archives, and Discord release notifications.
- Normalized addon title and version metadata used by the release pipeline.

## 12.0.5.0 — 2026-04-24

- Updated the addon for Midnight Patch 12.0.5 and its current endgame data.
- Modernized character collection, weekly reset handling, Mythic+ metadata requests, and stale expansion-data migration.
- Added Great Vault raid, dungeon, and world-activity tracking with reward item levels.
- Expanded tracking for Midnight weekly activities, PvP progress, catalyst charges, tier pieces, sparks, crests, keys, and other currencies.
- Added configurable minimum character/item levels and section visibility through the Retail Interface settings panel.
- Added safer event-driven refresh scheduling and reduced repeated work during combat and challenge modes.

## 12.0.0.1 — 2026-01-21

- Updated the addon for the Midnight pre-patch (`Interface 120000`).
- Added the initial Midnight dungeon, reward-level, tier, currency, and weekly-quest data.
- Added expansion-aware cleanup for incompatible saved character data.
- Added event-driven refreshes for quest, bag, and currency changes with safer Mythic+ metadata requests.
- Refactored legacy collection and rendering code for current Retail APIs.

## 11.2.0.0 — 2026-01-21

- Added The War Within Season 3 dungeon, tier, currency, catalyst, weekly quest, and world-event data.
- Added separate Great Vault raid, dungeon, and delve reward tracks.
- Expanded PvP tracking for Honor, Conquest, Forged Weapons progress, and Bloody Tokens.
- Added coffer-key progress and a wider set of endgame currencies.
- Added a catalyst interaction helper and refreshed the addon media/icon package.

## 10.2.0.3 — 2023-12-03

- Added weekly completion tracking for Time Rifts and Dreamsurges.
- Bumped the Patch 10.2 release metadata.

## 10.2.0.2 — 2023-11-27

- Fixed tier-piece counting across equipped items and bag contents.
- Corrected the third Mythic+ Great Vault slot to use the eighth qualifying run.
- Added the addon icon to TOC metadata.

## 10.2.0.1 — 2023-11-24

- Updated the Season 3 catalyst currency.
- Fixed stale-version data cleanup to compare against the active addon version.
- Corrected Season 3 Mythic+ Great Vault reward-level lookups.

## 10.2.0.0 — 2023-11-12

- Added Dragonflight Season 3 tier, dungeon, crest, Flightstone, and catalyst data.
- Added Dream Wardens and Blooming Dreamseeds weekly tracking.
- Improved keystone hyperlink parsing and stored explicit current-keystone details.
- Added cleanup for character data saved by older addon versions.

## 10.1.0.1 — 2023-06-15

- Updated dungeon and tier data for Dragonflight Season 2.
- Added catalyst-charge and upgrade-crest tracking.
- Updated Mythic+ Great Vault reward levels and support through keystone level 20.

## 10.0.5.2 — 2023-01-24

- Republished the 10.0.5 update under the corrected release tag; no separate functional changes were recorded from 10.0.5.1.

## 10.0.5.1 — 2023-01-24

- Added The Storm's Fury event tracking.
- Fixed Dragonflight world-quest weekly tracking.

## 10.0.2.3 — 2023-01-04

- Added progress and completion states for Aiding the Accord and Sparks of Life weeklies.
- Improved world-boss status and tier-set presentation.

## 10.0.2.2 — 2022-12-24

- Fixed Dragonflight keystone parsing from item hyperlinks.
- Corrected weekly quest completion checks.
- Improved tier-piece detection for equipped and bagged items.

## 10.0.2.1 — 2022-12-16

- Initial Dragonflight release with Season 1 dungeons and tier sets.
- Added Dragon Isles weekly quest, world-boss, currency, and keystone tracking.
- Removed obsolete Shadowlands covenant-resource tracking from the dashboard.

## 9.2.5.1 — 2022-08-08

- Updated the addon for Shadowlands Season 4.
- Refreshed Season 4 dungeon and version metadata.

## 9.2.0.5 — 2022-05-03

- Added tier-set tracking.
- Added the Improvised Cypher Analysis Tool bonus when calculating Cyphers of the First Ones.
- Fixed Mythic+ weekly reward tracking and removed the LibDialog dependency.

## 9.2.0.4 — 2022-04-26

- Added logic to determine the lowest qualifying keystone for each Great Vault reward bracket.
- Updated Patch 9.2 Interface metadata.

## 9.2.0.3 — 2022-04-20

- Fixed color-hex generation used by score and status text.

## 9.2.0.2 — 2022-04-20

- Added completed weekly keystone Great Vault rewards to the overview.

## 9.2.0.1 — 2022-03-28

- Updated quest, currency, dungeon, and Interface data for Shadowlands Patch 9.2.

## 9.1.5.0 — 2022-01-18

- Updated the addon for Shadowlands Patch 9.1.5.
- Removed obsolete Conduit Energy tracking.
- Fixed SavedVariables defaults, database migration, keystone status, and weekly quest resets.

## 2.6.3 — 2021-08-19

- Established the maintained MyAltManager fork and documented its alt, keystone, weekly quest, currency, and covenant overview features.
