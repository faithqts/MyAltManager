# MyAltManager
 
MyAltManager is a Retail WoW addon that tracks key endgame progress across your characters and shows it in one compact, sortable panel.

Current addon version: 12.0.5.0 (TOC interface 120005).

## What It Tracks

The addon stores data per character and displays it in columns.

- Character name, class color, realm, item level
- Tier set progress (set-piece count)
- Catalyst charges
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
	- Weekly Meta Quest
	- Special Assignment
	- Sath'theril Soiree
	- Abundant Offerings
	- Legends of the Haranir
	- Stormarian Assault
	- Hidden Trove
	- A Nightmarish Task
	- World Boss
- Currencies
	- Radiant Sparks
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
- Use settings to hide sections or specific rows you do not care about

## Credits

- Qooning - Tarren Mill, 2017-2020 (Method Alt Manager)
- Kabootzey - Tarren Mill, 2018 (Battle for Azeroth, AltManager)
- Faith - Frostmourne, Dragonflight, The War Within, and Midnight updates