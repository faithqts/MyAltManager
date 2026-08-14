# MyAltManager

MyAltManager is a Retail WoW addon that tracks key endgame progress across your characters and shows it in one compact, sortable panel.

Current addon version: 12.1.0.30 (TOC interface 120100).

See [MyAltManager Patch Notes](CHANGELOG.md) for the complete version history.

## What It Tracks

The addon stores data per character and displays it in columns.

- Character name, class color, realm, item level
- Season 2 tier set progress (Season 1 pieces are ignored)
- Season 2 catalyst charges
- Mythic+
	- Overall rating
	- Current keystone (level + dungeon)
	- Highest completed weekly key
- Great Vault progress
	- Weekly raid reward track
	- Weekly dungeon reward track
	- Weekly activity (delve) reward track
- PvP
	- Honor
	- Conquest
	- Forged Weapons progress
	- Bloody Tokens
- Weekly activity status
	- Weekly Meta Quest (Trailing Xal'atath)
	- Turn Back the Surge
	- Purging the Vaults
	- Sath'theril Soiree
	- Abundant Offerings
	- Legends of the Haranir
	- Stormarian Assault
	- Midnight: World Tour
	- Hidden Trove (Delves)
	- A Nightmarish Task
	- World Boss
- Currencies
	- Tidal Sparks
	- Adventurer, Veteran, Champion, Hero, and Myth crests
	- Bountiful Keys and Coffer Key Shards
	- Undercoin
	- Angler Pearls
	- Voidlight Marl
	- Shard of Dundun
	- Remnant of Anguish
	- Unalloyed Abundance
	- Nebulous Cores
	- Untainted Mana-Crystal
	- Field Accolade
	- Luminous Dust
	- Brimming Arcana

## Slash Commands

- /alts
	- Open the main window
- /alts settings
	- Open addon settings in the WoW Settings UI
- /alts min <ilevel>
	- Set minimum item level required before character data is stored
- /alts remove <name>
	- Remove all stored characters with that exact character name
- /alts purge
	- Wipe all stored addon data
- /alts help
	- Print command help

## Settings

The addon registers a settings category named MyAltManager with:

- Minimum Level slider (80-90)
- Minimum Item Level slider (0-500)
- Curse Surge tracker width, height, text size, and background opacity sliders
- Show Icons toggle
- Section visibility toggles
- Child-row toggles for grouped sections (PvP, Weekly Quests, Currencies)

## Data Behavior

- Data is stored in SavedVariables: MyAltManagerDB
- Data collection is gated to avoid collecting in combat/challenge mode contexts
- Data refresh is triggered on login and key gameplay events (quests, bags, currency updates, weekly-related updates)
- Entries can expire/reset around weekly reset for weekly-progress fields
- Includes one-time per-expansion migration logic that resets stale saved data while preserving config

## Usage Notes

- Open with /alts
- Window is draggable
- Characters are shown in descending item-level order
- The footer shows the next Curse Surge on its 45-minute schedule, including its two-minute starting and three-minute active phases
- Click the Curse Surge footer to toggle a draggable standalone progress bar
- The standalone tracker includes a height-matched Curse Surge icon inside the bar, with padded status text, and names the next scheduled surge event when Blizzard provides its POI name
- While that tracker is visible, the active Curse Surge is automatically focused on the map when its starting phase begins
- Use settings to hide sections or specific rows you do not care about

## Credits

- Qooning - Tarren Mill, 2017-2020 (Method Alt Manager)
- Kabootzey - Tarren Mill, 2018 (Battle for Azeroth, AltManager)
- Faith - Frostmourne, Dragonflight, The War Within, and Midnight updates
