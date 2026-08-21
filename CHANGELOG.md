# MyAltManager Patch Notes

This file records the user-facing changes for each version represented in the repository. Older entries are reconstructed from the corresponding tagged or versioned commits.

## 12.1.0.64 — 2026-08-21

- Changed dashboard character ordering from descending item level to alphabetical character name, retiring the legacy saved sort value so the new order applies immediately.

## 12.1.0.63 — 2026-08-21

- Kept `Converting` at the exact same centered position and size as the normal Coffer Key Shards text while its cast-progress strip appears underneath.
- Styled the eligible `Convert Keys` state with the same solid green background used by completed Great Vault segments.

## 12.1.0.62 — 2026-08-21

- Removed the Currencies and PvP sections from the expanded character drawer while retaining their collection and saved values; dashboard currencies remain visible.

## 12.1.0.61 — 2026-08-21

- Added comma-separated thousands to dashboard and drawer currencies, Mythic+ score, item levels, PvP balances, weekly count progress, and the Coffer Key Glue tooltip.

## 12.1.0.60 — 2026-08-21

- Added live Coffer Key Glue cast feedback: once the cast begins, `Convert Keys` changes to `Converting` with a compact progress bar beneath it and resets cleanly when the cast completes, fails, or is interrupted.
- Raised the MyAltManager dashboard and its secure conversion click layer to fullscreen-dialog strata so the complete window stays above other game and addon frames.
- Filled currencies without minimum, maximum, or rolling progress completely with the standard gold currency progress colour.

## 12.1.0.59 — 2026-08-21

- Expanded the Coffer Key Glue secure click target to the rendered bounds of both the shard icon and progress bar, so clicking the icon, `Convert Keys` text, or anywhere across the bar activates the toy.

## 12.1.0.58 — 2026-08-21

- Removed the redundant visible border from the transparent Coffer Key Glue secure overlay and now detach it before the dashboard closes, preventing an outline from remaining on screen.
- Stopped rebuilding currency rows immediately after every click; failed casts while moving leave the dashboard untouched, while successful casts still refresh through the glue spell and currency-update events.

## 12.1.0.57 — 2026-08-21

- Changed `Convert Keys` to the secure item-action pattern used by working toy buttons: a left-click `item` action with `item:267291` as its protected attribute.
- Reverted the green currency completion styling, restoring the previous dark backgrounds and gold rolling-progress fills while retaining numeric capped values such as `600/600`.

## 12.1.0.56 — 2026-08-21

- Fixed the `Convert Keys` click to invoke Coffer Key Glue through the client's native secure toy action instead of the non-functional `/use item:267291` macro form.
- Retained the secure out-of-combat visibility guard and post-click currency refresh.

## 12.1.0.55 — 2026-08-21

- Fixed `Convert Keys` eligibility to use live Coffer Key Shards data for the logged-in character instead of allowing a legacy saved payload to keep the action hidden.
- Recognized Coffer Key Glue through its known spell as well as its toy or physical item state.

## 12.1.0.54 — 2026-08-21

- Ensured `Convert Keys` takes priority whenever more than 100 Coffer Key Shards are spendable and Coffer Key Glue can be used, including after reaching the weekly-earned cap.
- Kept the green numeric cap display for cases where conversion is unavailable.

## 12.1.0.53 — 2026-08-21

- Widened the currency area by 60 pixels, adding 20 pixels to each of its three currency progress bars.
- Styled flat currency totals and capped rolling totals with the same green completion background as the Great Vault while retaining the existing in-progress colours.
- Kept Coffer Key Shards numeric at the weekly cap, displaying `600/600` on the green background instead of `Weekly Cap`.

## 12.1.0.52 — 2026-08-21

- Fixed Coffer Key Shards to read Blizzard's weekly-earned and weekly-maximum currency fields, so progress such as `225/600` no longer collapses to the available balance as `25/25`.
- Kept Coffer Key Glue conversion eligibility tied to the actual spendable shard balance, independently of the weekly progress shown on the dashboard.

## 12.1.0.51 — 2026-08-21

- Removed dashboard section, currency, weekly-row, PvP, and other content visibility options from the addon settings.
- Made all supported dashboard columns and drawer details permanently available, ignoring and clearing legacy visibility choices and always enabling character drawers.
- Kept settings focused on minimum tracked levels and visual sizing, plus the separate opt-in control required before sending Curse Surge announcements to guild chat.

## 12.1.0.50 — 2026-08-21

- Restricted the Coffer Key Glue secure action to out-of-combat use and added a combat guard inside its secure macro.
- Changed Coffer Key Shards to show `Convert Keys` only when conversion is available, otherwise display the available shards against the spend-adjusted remaining weekly allowance, such as `25/400` after earning 225 and converting 200.
- Added a green `Weekly Cap` state once the true weekly-earned total reaches its maximum, and refreshed the stored currency state immediately after the secure conversion click or glue spell succeeds.

## 12.1.0.49 — 2026-08-21

- Added a secure Coffer Key Glue action over the logged-in character's Coffer Key Shards currency when the toy is known and more than 100 shards are available.
- Clicking the highlighted shard currency now uses Coffer Key Glue to convert the available shards into Restored Coffer Keys.
- Kept the secure overlay independent from pooled dashboard rows and automatically hidden during combat or whenever the dashboard is closed.

## 12.1.0.48 — 2026-08-21

- Expanded the dashboard currency area to three fixed columns containing Tidal Spark Dust, Nebulous Voidcore, Restored Coffer Keys; Champion, Hero, and Myth Crests; and Voidlight Marl, Undercoin, and Coffer Key Shards.
- Displayed flat available totals for Nebulous Voidcore, Restored Coffer Keys, Voidlight Marl, and Undercoin, while retaining current/weekly-maximum progress for sparks, crests, and Coffer Key Shards.
- Added the weekly-highest keystone below the current keystone as a third Mythic+ line, with explicit empty states, and inset the close button from the window border.

## 12.1.0.47 — 2026-08-21

- Fixed the standalone Curse Surge tracker to resolve Blizzard's `Curse Surge:`-prefixed event names through the addon's short-name and coordinate table.
- Kept every tracker phase concise as `Next: Short Event Name`, `Starting: Short Event Name`, or `Active: Short Event Name`.

## 12.1.0.46 — 2026-08-18

- Removed the coordinates from the standalone Curse Surge tracker, leaving just the phase and surge name.

## 12.1.0.45 — 2026-08-18

- Restored the clickable map pin in the Curse Surge guild announcement, placed after the coordinates.
- Built the pin from the client's own waypoint hyperlink, which survives being sent by an addon where a composed link did not.
- Saved and restored any waypoint and super-tracking you already had, so the announcement leaves your own map pin untouched.

## 12.1.0.44 — 2026-08-18

- Tracked Hidden Trove (Delves) from the Unlocking cast (spell 1248091) that opens the trove instead of a quest ID, so the row keeps working when the quest ID is re-issued each season.
- Recorded the completion per character against the weekly reset, and cleared it automatically once that reset passes.
- Kept the completion even when it is opened in combat or mid-delve, where data collection is deferred.

## 12.1.0.43 — 2026-08-17

- Shortened the Curse Surge names shown in the tracker, the footer tooltip, and the guild announcement to Looming Mutagenitor, Mlurkkr Massacre, Malformed Leviathan, Broodmother's Nest, and Whispering Marsh.
- Kept matching on Blizzard's full event name and the boss name, so the shorter labels do not affect location lookup.

## 12.1.0.42 — 2026-08-17

- Named the surge in the standalone tracker's starting and active states, replacing "Curse Surge Starting" and "Curse Surge Active" with "Starting: <event>" and "Active: <event>".

## 12.1.0.41 — 2026-08-17

- Added the Curse Surge coordinates as `(xx, yy)` after the event text on the standalone tracker, in the same gold as the window header.

## 12.1.0.40 — 2026-08-17

- Made clicking the standalone Curse Surge tracker place and track a map pin at the surge, or clear it when that surge is already tracked.
- Kept dragging the tracker to a new position from registering as a click.

## 12.1.0.39 — 2026-08-17

- Replaced the map pin link in the Curse Surge guild announcement with plain coordinates, because WoW strips hyperlinks from messages sent by addons and the link arrived as dead text.

## 12.1.0.38 — 2026-08-17

- Sent the Curse Surge announcement to guild chat, renaming the setting to Announce Next Curse Surge to Guild.
- Included the countdown, surge name, plain coordinates, and a clickable map pin link in the announcement.
- Printed to your own chat instead when you are not in a guild.

## 12.1.0.37 — 2026-08-17

- Saved the announced Curse Surge to disk, so a reload, a relog, or swapping characters mid-countdown can never repeat an announcement.

## 12.1.0.36 — 2026-08-17

- Added an Announce Next Curse Surge setting, off by default, that prints one chat message five minutes before each surge naming it and linking a clickable map pin.
- Held the announcement back while in combat and released it on leaving combat, so it never fires under combat restrictions.
- Limited the announcement to once per surge, and fell back to a bare countdown if the surge is still unnamed a minute into the window.

## 12.1.0.35 — 2026-08-17

- Made the Curse Surge footer coordinates a toggle, clearing the pin and focus tracking when that surge is already the tracked waypoint.
- Switched the tooltip to read "Click to remove focus tracking." while that surge is tracked, and kept "Click to track this location." otherwise.

## 12.1.0.34 — 2026-08-17

- Requested the Curse Surge schedule at login and retried until the surge is named, so its location is known without opening the map or the events tab.
- Refreshed the surge name, footer, and standalone tracker whenever Blizzard's Event Scheduler pushes new data.

## 12.1.0.33 — 2026-08-17

- Dropped the brackets around the Curse Surge footer coordinates and coloured them with the same gold as the MyAltManager window header.

## 12.1.0.32 — 2026-08-17

- Added the Curse Surge spawn coordinates to the footer once the scheduled surge is identified, shown after the countdown clock or the Starting and Active labels.
- Clicking those coordinates places a map pin at the surge and super-tracks it, without showing or hiding the standalone Curse Surge tracker.
- Resolved the scheduled surge event whenever the main window is open, not only while the standalone tracker is visible.

## 12.1.0.31 — 2026-08-17

- Switched World Boss tracking to the new per-character quest, Lair: Nymrissa Wavecaller, so each alt shows its own completion instead of an account-wide result.
- Retired the previous account-wide world boss quest IDs, which are kept commented out for reference.

## 12.1.0.30 — 2026-08-14

- Made the standalone Curse Surge timer visibility character-specific while preserving its shared position and appearance settings.
- Migrated the former shared enabled state to the first character loaded after updating.

## 12.1.0.29 — 2026-08-14

- Matched the scale label, percentage, and button text sizes and changed the label to the same bright text color as the percentage.

## 12.1.0.28 — 2026-08-14

- Tightened the title-bar scale control spacing and replaced the default panel buttons with compact flat buttons styled to match MyAltManager.

## 12.1.0.27 — 2026-08-14

- Renamed the weekly quest display from `Curse Surges` to `Turn Back the Surge` while retaining its live `X/3` progress.
- Added live `X/4` progress for Midnight: World Tour, excluding the optional Lor'themar conversation objective.

## 12.1.0.26 — 2026-08-14

- Widened the main dashboard so all six weekly quests fit on one drawer row.
- Added a persistent title-bar scale control with 5% decrease and increase buttons and a displayed percentage.

## 12.1.0.25 — 2026-08-14

- Added live in-progress counts to Curse Surges and A Nightmarish Task in character drawers.
- Added live percentage progress to Purging the Vaults without duplicating the percent symbol.

## 12.1.0.24 — 2026-08-13

- Added the Curse Surge poison-buff icon inside the left edge of the standalone tracker, sized as a square matching the configured progress-bar height, rendered above the bar fill, with padding before the status text.
- Kept the tracker's outer border above both the icon and progress fill, and added a matching border-colored divider between the icon and status text.
- Replaced the waiting label with `Next: <event name>` whenever Blizzard's Event Scheduler provides the next Curse Surge POI name.

## 12.1.0.23 — 2026-08-13

- Automatically focus the in-game Events entry for a Curse Surge when its two-minute starting phase begins and the standalone tracker is visible.
- Resolve the matching scheduled event from Blizzard's Event Scheduler data and focus it once per surge without opening the world map.

## 12.1.0.22 — 2026-08-13

- Split each Curse Surge window into a two-minute `Curse Surge Starting` phase followed by a three-minute `Curse Surge Active` phase.
- Added an independent countdown for each phase.
- Inverted the standalone tracker during the starting and active phases so its progress bar depletes toward zero; the waiting phase continues filling toward the next surge.

## 12.1.0.21 — 2026-08-13

- Replaced the Special Assignment weekly tracker with `Purging the Vaults` (quest ID `95520`).
- Renamed the weekly quest display from `Hidden Trove` to `Hidden Trove (Delves)`.

## 12.1.0.20 — 2026-08-13

- Added `Midnight: World Tour` (quest ID `95245`) to World Events.
- Placed the parent quest after its four component events in the character information drawer and Interface visibility settings.

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
