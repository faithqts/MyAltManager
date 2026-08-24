local _, AltManager = ...

_G["AltManager"] = AltManager

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 2020-10-14
-- updates for Dragonflight, and The War Within by: Faith - Frostmourne, 2021-2024
-- Last edit: 2023-11-12
-- updates for Midnight pre-patch 12.0 by: Faith - Frostmourne, 2026-01-21
-- updates for Midnight season 2 patch 12.1 by: Faith - Frostmourne, 2026-08-12

local addon = "MyAltManager"
local remove_button_size = 16

local constants = {}
AltManager.constants = constants

constants.DATA_SCHEMA = 2
constants.layout = {
    FRAME_WIDTH = 1140,
    PAD_X = 14,
    COL_GAP = 10,
    COL_CHARACTER = 250,
    COL_MPLUS = 110,
    COL_VAULT = 370,
    COL_CURRENCY = 352,
    ROW_HEIGHT = 58,
    HEADER_HEIGHT = 26,
    TITLE_HEIGHT = 32,
    FOOTER_HEIGHT = 18,
    STRIPE_W = 4,
    STRIPE_H = 46,
    BAR_H = 12,
    BAR_GAP = 3,
    VAULT_LABEL_W = 58,
    ICON_SIZE = 14,
}

constants.colors = {
    frameTop = { 0x1D / 255, 0x19 / 255, 0x25 / 255, 1 },
    frameBottom = { 0x17 / 255, 0x13 / 255, 0x1E / 255, 1 },
    frameBorder = { 0x44 / 255, 0x3C / 255, 0x53 / 255, 1 },
    titleTop = { 0x25 / 255, 0x20 / 255, 0x30 / 255, 1 },
    titleBottom = { 0x1D / 255, 0x19 / 255, 0x27 / 255, 1 },
    titleText = { 0xD8 / 255, 0xC9 / 255, 0x9C / 255, 1 },
    rowSeparator = { 0x2B / 255, 0x25 / 255, 0x35 / 255, 1 },
    body = { 0xC5 / 255, 0xC0 / 255, 0xCD / 255, 1 },
    brightText = { 1, 1, 1, 1 },
    muted = { 0x90 / 255, 0x89 / 255, 0x9A / 255, 1 },
    header = { 0xAA / 255, 0xA3 / 255, 0xB5 / 255, 1 },
    gold = { 0xD8 / 255, 0xB8 / 255, 0x5A / 255, 1 },
    goldDark = { 0xAD / 255, 0x87 / 255, 0x36 / 255, 1 },
    barEmpty = { 0x24 / 255, 0x20 / 255, 0x2D / 255, 1 },
    barBorder = { 0x3A / 255, 0x34 / 255, 0x45 / 255, 1 },
    vaultComplete = { 0x2F / 255, 0x7D / 255, 0x4A / 255, 1 },
    vaultProgress = { 0xA6 / 255, 0x5A / 255, 0x2E / 255, 1 },
    vaultNotStarted = { 0x6E / 255, 0x2D / 255, 0x35 / 255, 1 },
    vaultText = { 1, 1, 1, 1 },
    currencyFill = { 0x82 / 255, 0x68 / 255, 0x34 / 255, 1 },
    currencyText = { 0xF3 / 255, 0xF0 / 255, 0xF5 / 255, 1 },
    success = { 0x8B / 255, 0xC9 / 255, 0x82 / 255, 1 },
    danger = { 0xE4 / 255, 0x7A / 255, 0x74 / 255, 1 },
    warning = { 0xDD / 255, 0xA0 / 255, 0x6E / 255, 1 },
    inProgress = { 0xD8 / 255, 0xB8 / 255, 0x5A / 255, 1 },
    drawerHeading = { 0xB7 / 255, 0xB0 / 255, 0xC1 / 255, 1 },
    drawerDivider = { 0x32 / 255, 0x2C / 255, 0x3C / 255, 1 },
}

local function CopyKeyValues(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

local function MergeKeyValues(base, overrides)
    local merged = CopyKeyValues(base)
    for key, value in pairs(overrides or {}) do
        merged[key] = value
    end
    return merged
end

constants.config = {}
constants.config.MIN_LEVEL = 80
constants.config.MIN_ITEM_LEVEL = 0 -- controlled via settings panel
constants.config.COLLECT_MIN_INTERVAL_SECONDS = 1.5
constants.config.MYTHICPLUS_METADATA_MIN_INTERVAL_SECONDS = 20
constants.config.UI_SCALE = 1.10
constants.config.UI_SCALE_MIN = 0.50
constants.config.UI_SCALE_MAX = 1.50
constants.config.UI_SCALE_STEP = 0.05

constants.ACTIVE_SEASON_ID = 2
constants.CURSE_SURGE = {
    INTERVAL_SECONDS = 45 * 60,
    STARTING_SECONDS = 2 * 60,
    ACTIVE_SECONDS = 5 * 60,
    EVENT_START_TOLERANCE_SECONDS = 60,
    -- 2026-08-12 17:00 GMT+8 (09:00 UTC), supplied launch-day observation.
    ANCHOR_EPOCH = 1786525200,
    -- Login-time retries while the scheduler and area POI data settle.
    PRIME_ATTEMPTS = 12,
    PRIME_INTERVAL_SECONDS = 5,
    -- Optional chat announcement, opt-in via settings.
    ANNOUNCE_LEAD_SECONDS = 5 * 60,
    -- If the scheduler still has not named the surge by here, announce without a location.
    ANNOUNCE_FALLBACK_SECONDS = 4 * 60,
    ANNOUNCE_POLL_SECONDS = 10,
}
constants.WEEK_SECONDS = 7 * 24 * 60 * 60
constants.WEEKLY_META_QUEST = {
    QUEST_ID = 98172, -- Trailing Xal'atath
}
-- Hidden Trove (Delves) is tracked from the cast that opens the trove rather than from a quest ID,
-- because the quest ID is re-issued every season while the "Unlocking" cast is not. The trove is
-- weekly and per-character, so the completion is stored per GUID and expires at the weekly reset.
constants.HIDDEN_TROVE = {
    SPELL_IDS = { 1248091 }, -- 1248091 = Unlocking (Open Object, 1.5s cast)
}
constants.COFFER_KEY_GLUE = {
    ITEM_ID = 267291,
    SPELL_ID = 1280020,
    MIN_SHARDS_EXCLUSIVE = 100,
}
constants.CURSE_SURGE_TRACKER = {
    WIDTH = 360,
    HEIGHT = 30,
    FONT_SIZE = 12,
    BACKGROUND_OPACITY = 85,
}
-- Curse Surge spawn points. `name` is what the UI displays; `event` is the scheduled event name
-- Blizzard reports for the area POI and `target` is the boss that spawns there. All three are
-- matched, so whichever label the POI carries still resolves a location.
constants.CURSE_SURGE_LOCATIONS = {
    { name = "Looming Mutagenitor", event = "Curse Surge: The Looming Mutagenitor",       target = "Looming Mutagenitor",             uiMapID = 2512, x = 26.7, y = 64.8 },
    { name = "Mlurkkr Massacre",    event = "Curse Surge: Mlurkkr Massacre",              target = "Ss'akrithos",                     uiMapID = 2512, x = 71.2, y = 31.3 },
    { name = "Malformed Leviathan", event = "Curse Surge: The Malformed Leviathan",       target = "Malformed Leviathan",             uiMapID = 2512, x = 46.9, y = 62.2 },
    { name = "Broodmother's Nest",  event = "Curse Surge: The Broodmother's Nest",        target = "Vassti, the Exalted Broodmother", uiMapID = 2512, x = 45.2, y = 28.6 },
    { name = "Whispering Marsh",    event = "Curse Surge: Siege at the Whispering Marsh", target = "Venom Lancer Ori'kassi",          uiMapID = 2512, x = 67.6, y = 77.8 },
}

constants.labels = {
    NAME = "",
    WEEKLY_HIGHEST = "Weekly Highest",
    CURRENT_KEYSTONE = "Current Keystone",
    WEEKLY_QUESTS = "Weekly Quests",
    WEEKLY_EVENTS = "Weekly Events",
    KEYSTONE = "Mythic+",
    MYTHIC_RATING = "Overall Rating",
    WEEKLY_KEYSTONE_REWARDS = "Weekly Keystones",
    WEEKLY_RAID_REWARDS = "Weekly Raids",
    WEEKLY_DUNGEON_REWARDS = "Weekly Dungeons",
    WEEKLY_DELVE_REWARDS = "Weekly Activities",
    TIER_SET = "Tier (S2)",
    CATALYST_CHARGES = "Catalyst Charges",
    CURRENCIES = "Currencies",
    CONQUEST = "Conquest |TInterface\\Icons\\achievement_legionpvp2tier3:12:12:0:0|t",
    FORGED_WEAPONS = "Forged Weapons |TInterface\\Icons\\inv_misc_token_pvp02:12:12:0:0|t",
    HONOR = "Honor |TInterface\\Icons\\achievement_legionpvptier4:12:12:0:0|t",
    BLOODY_TOKENS = "Bloody Tokens |TInterface\\Icons\\inv_10_dungeonjewelry_titan_trinket_2_color2:12:12:0:0|t",
    ADVENTURER_CRESTS = "Adventurer Crests |TInterface\\Icons\\inv_120_crest_adventurer:12:12:0:0|t",
    VETERAN_CRESTS = "Veteran Crests |TInterface\\Icons\\inv_120_crest_veteran:12:12:0:0|t",
    CHAMPION_CRESTS = "Champion Crests |TInterface\\Icons\\inv_120_crest_champion:12:12:0:0|t",
    HERO_CRESTS = "Hero Crests |TInterface\\Icons\\inv_120_crest_hero:12:12:0:0|t",
    MYTH_CRESTS = "Myth Crests |TInterface\\Icons\\inv_120_crest_myth:12:12:0:0|t",
    UNDERCOIN = "Undercoin |TInterface\\Icons\\inv_misc_elvencoins:12:12:0:0|t",
    ANGLER_PEARLS = "Angler Pearls |T348545:12:12:0:0|t",
    TIDAL_SPARKS = "Tidal Spark Dust |TInterface\\Icons\\inv_enchanting_dust_color5:12:12:0:0|t",
    HIDDEN_TROVE = "Hidden Trove (Delves)",
    RESTORED_COFFER_KEY = "Restored Coffer Keys |TInterface\\Icons\\inv_10_blacksmithing_consumable_key_color1:12:12:0:0|t",
    COFFER_KEY_SHARDS = "Coffer Key Shards |TInterface\\Icons\\inv_gizmo_hardenedadamantitetube:12:12:0:0|t",
    VOIDLIGHT_MARL = "Voidlight Marl |TInterface\\Icons\\inv_112_raidtrinkets_voidprism:12:12:0:0|t",
    WEEKLY_META_QUEST = "Weekly Meta Quest",
    CURSE_SURGES = "Turn Back the Surge",
    SATHTHERIL_SOIREE = "Sath'theril Soiree",
    PURGING_THE_VAULTS = "Purging the Vaults",
    ABUNDANT_OFFERINGS = "Abundant Offerings",
    LEGENDS_OF_THE_HARANIR = "Legends of the Haranir",
    STORMARIAN_ASSAULT = "Stormarian Assault",
    MIDNIGHT_WORLD_TOUR = "Midnight: World Tour",
    NIGHTMARISH_TASK = "A Nightmarish Task",
    GREAT_VAULT_REWARDS = "Great Vault",
    WORLD_BOSS = "World Boss",
    PVP = "PVP",
    SHARD_OF_DUNDUN = "Shard of Dundun |TInterface\\Icons\\inv_ore_feliron:12:12:0:0|t",
    REMNANT_OF_ANGUISH = "Remnant of Anguish |TInterface\\Icons\\inv_10_elementalcombinedfoozles_blood:12:12:0:0|t",
    UNALLOYED_ABUNDANCE = "Unalloyed Abundance |TInterface\\Icons\\inv_10_gathering_bioluminescentspores_large:12:12:0:0|t",
    NEBULOUS_VOIDCORE = "Nebulous Voidcore",
    UNTAINTED_MANA_CRYSTAL = "Untainted Mana-Crystal |T5931199:12:12:0:0|t",
    FIELD_ACCOLADE = "Field Accolade |TInterface\\Icons\\inv_belt_armor_bloodelf_d_01:12:12:0:0|t",
    LUMINOUS_DUST = "Luminous Dust |TInterface\\Icons\\inv_misc_dust_05:12:12:0:0|t",
    BRIMMING_ARCANA = "Brimming Arcana |TInterface\\Icons\\inv_elemental_primal_mana:12:12:0:0|t",
}

constants.sections = {
    { key = "mythic_plus",    label = "Mythic+",              keys = { "mythic_title", "mythic_rating", "current_keystone", "weekly_highest" } },
    { key = "great_vault",    label = "Great Vault",          keys = { "great_vault_rewards", "weekly_raid_rewards", "weekly_key_rewards", "weekly_delve_rewards" } },
    {
        key = "pvp", label = "PVP",
        keys = { "pvp_data", "pvp_honor", "pvp_conquest", "pvp_conquest_earned", "pvp_bloody_tokens" },
        children = {
            { key = "pvp_honor",           label = "Honor",          icon = constants.labels.HONOR:match("|T[^|]-|t") },
            { key = "pvp_conquest",         label = "Conquest",       icon = constants.labels.CONQUEST:match("|T[^|]-|t") },
            { key = "pvp_conquest_earned",  label = "Forged Weapons", icon = constants.labels.FORGED_WEAPONS:match("|T[^|]-|t") },
            { key = "pvp_bloody_tokens",    label = "Bloody Tokens",  icon = constants.labels.BLOODY_TOKENS:match("|T[^|]-|t") },
        },
    },
    {
        key = "world_events", label = constants.labels.WEEKLY_EVENTS,
        keys = { "world_events", "saththeril_soiree", "stormarian_assault", "legends_of_the_haranir", "abundant_offerings", "midnight_world_tour" },
        children = {
            { key = "saththeril_soiree",      dataKey = "saththerilSoiree",     label = "Sath'theril Soiree" },
            { key = "stormarian_assault",     dataKey = "stormarianAssault",   label = "Stormarian Assault" },
            { key = "legends_of_the_haranir", dataKey = "legendsOfTheHaranir", label = "Legends of the Haranir" },
            { key = "abundant_offerings",     dataKey = "abundantOfferings",    label = "Abundant Offerings" },
            { key = "midnight_world_tour",    dataKey = "midnightWorldTour",    label = "Midnight: World Tour", alwaysLast = true },
        },
    },
    {
        key = "weekly_quests", label = "Weekly Quests",
        keys = { "weekly_quests", "weekly_meta_quest", "curse_surges", "purging_the_vaults", "hidden_trove", "nightmarish_task", "world_boss" },
        children = {
            { key = "weekly_meta_quest",       dataKey = "weeklyMetaQuest",      label = "Weekly Meta Quest" },
            { key = "curse_surges",            dataKey = "curseSurges",          label = "Turn Back the Surge" },
            { key = "purging_the_vaults",      dataKey = "purgingTheVaults",     label = "Purging the Vaults" },
            { key = "hidden_trove",            dataKey = "hiddenTrove",          label = "Hidden Trove (Delves)" },
            { key = "nightmarish_task",        dataKey = "nightmarishTask",       label = "A Nightmarish Task" },
            { key = "world_boss",              dataKey = "worldBoss",            label = "World Boss" },
        },
    },
    {
        key = "currencies", label = "Currencies",
        keys = { "currencies", "tidalSparks", "adventurer_crests", "veteran_crests", "champion_crests", "hero_crests", "myth_crests", "nebulousVoidcore", "restored_coffer_keys", "coffer_key_shards", "undercoin", "anglerPearls", "voidlightMarl", "shardOfDundun", "remnantOfAnguish", "unalloyedAbundance", "untaintedManaCrystal", "fieldAccolade", "luminousDust", "brimmingArcana" },
        children = {
            { key = "tidalSparks",         label = "Tidal Spark Dust",    icon = constants.labels.TIDAL_SPARKS:match("|T[^|]-|t") },
            { key = "adventurer_crests",   label = "Adventurer Crests",   icon = constants.labels.ADVENTURER_CRESTS:match("|T[^|]-|t") },
            { key = "veteran_crests",      label = "Veteran Crests",      icon = constants.labels.VETERAN_CRESTS:match("|T[^|]-|t") },
            { key = "champion_crests",     label = "Champion Crests",     icon = constants.labels.CHAMPION_CRESTS:match("|T[^|]-|t") },
            { key = "hero_crests",         label = "Hero Crests",         icon = constants.labels.HERO_CRESTS:match("|T[^|]-|t") },
            { key = "myth_crests",         label = "Myth Crests",         icon = constants.labels.MYTH_CRESTS:match("|T[^|]-|t") },
            { key = "nebulousVoidcore",    label = "Nebulous Voidcore",  icon = constants.labels.NEBULOUS_VOIDCORE:match("|T[^|]-|t") },
            { key = "restored_coffer_keys", label = "Restored Coffer Keys", icon = constants.labels.RESTORED_COFFER_KEY:match("|T[^|]-|t") },
            { key = "coffer_key_shards",   dataKey = "cofferKeyShards", label = "Coffer Key Shards", icon = constants.labels.COFFER_KEY_SHARDS:match("|T[^|]-|t") },
            { key = "undercoin",           label = "Undercoin",           icon = constants.labels.UNDERCOIN:match("|T[^|]-|t") },
            { key = "anglerPearls",        label = "Angler Pearls",       icon = constants.labels.ANGLER_PEARLS:match("|T[^|]-|t") },
            { key = "voidlightMarl",       label = "Voidlight Marl",      icon = constants.labels.VOIDLIGHT_MARL:match("|T[^|]-|t") },
            { key = "shardOfDundun",       label = "Shard of Dundun",     icon = constants.labels.SHARD_OF_DUNDUN:match("|T[^|]-|t") },
            { key = "remnantOfAnguish",    label = "Remnant of Anguish",  icon = constants.labels.REMNANT_OF_ANGUISH:match("|T[^|]-|t") },
            { key = "unalloyedAbundance",  label = "Unalloyed Abundance", icon = constants.labels.UNALLOYED_ABUNDANCE:match("|T[^|]-|t") },
            { key = "untaintedManaCrystal", label = "Untainted Mana-Crystal", icon = constants.labels.UNTAINTED_MANA_CRYSTAL:match("|T[^|]-|t") },
            { key = "fieldAccolade",       label = "Field Accolade",      icon = constants.labels.FIELD_ACCOLADE:match("|T[^|]-|t") },
            { key = "luminousDust",        label = "Luminous Dust",       icon = constants.labels.LUMINOUS_DUST:match("|T[^|]-|t") },
            { key = "brimmingArcana",      label = "Brimming Arcana",     icon = constants.labels.BRIMMING_ARCANA:match("|T[^|]-|t") },
        },
    },
}

constants.DUNGEONS = {
    [2] = "Serpent",
    [56] = "Brewery",
    [57] = "Setting Sun",
    [58] = "Monastery",
    [59] = "Niuzao",
    [60] = "Mogu'shan",
    [76] = "Scholomance",
    [77] = "Halls",
    [78] = "Monastery",
    [161] = "Skyreach",
    [163] = "Bloodmaul",
    [164] = "Auchindoun",
    [165] = "Shadowmoon",
    [166] = "Depot",
    [167] = "UBRS",
    [168] = "Everbloom",
    [169] = "Docks",
    [197] = "Azshara",
    [198] = "Darkheart",
    [199] = "Black Rook",
    [200] = "Valor",
    [206] = "Lair",
    [207] = "Wardens",
    [208] = "Maw",
    [209] = "Arcway",
    [210] = "Court",
    [227] = "Kara: Lower",
    [233] = "Eternal Night",
    [234] = "Kara: Upper",
    [239] = "Triumvirate",
    [244] = "Atal'Dazar",
    [245] = "Freehold",
    [246] = "Tol Dagor",
    [247] = "Motherlode",
    [248] = "Waycrest",
    [249] = "Kings Rest",
    [250] = "Sethraliss",
    [251] = "Underrot",
    [252] = "Storm",
    [353] = "Boralus",
    [369] = "Junkyard",
    [370] = "Workshop",
    [375] = "Mists",
    [376] = "Necrotic",
    [377] = "DoS",
    [378] = "Atonement",
    [379] = "Plaguefall",
    [380] = "Sanguine",
    [381] = "Spires",
    [382] = "Theater",
    [391] = "Streets",
    [392] = "Gambit",
    [399] = "Ruby",
    [400] = "Nokhud",
    [401] = "Azure",
    [402] = "Academy",
    [403] = "Uldaman",
    [404] = "Neltharus",
    [405] = "Brackenhide",
    [406] = "Infusion",
    [438] = "Vortex",
    [456] = "Tides",
    [463] = "Galakrond",
    [464] = "Murozond",
    [499] = "Priory",
    [500] = "Rookery",
    [501] = "Stonevault",
    [502] = "Threads",
    [503] = "Ara-Kara",
    [504] = "Darkflame",
    [505] = "Dawnbreaker",
    [506] = "Meadery",
    [507] = "Grim Batol",
    [525] = "Floodgate",
    [541] = "Stonecore",
    [542] = "Eco-Dome",
    [556] = "Saron",
    [557] = "Windrunner",
    [558] = "Magisters",
    [559] = "Xenas",
    [560] = "Maisara",
}

local BASE_CURRENCIES = {
    conquest = 1602,
    honor = 1792,
    bloodyTokens = 2123,
    undercoin = 2803,
    anglerPearls = 3373,
    voidlightMarl = 3316,
    restored_coffer_keys = 3028,
    cofferKeyShards = 3310,
    shardOfDundun = 3376,
    remnantOfAnguish = 3392,
    unalloyedAbundance = 3377,
    nebulousVoidcore = 3418,
    untaintedManaCrystal = 3356,
    fieldAccolade = 3405,
    luminousDust = 3385,
    brimmingArcana = 3379,
}

local SEASON1_CURRENCIES = {
    catalyst = 3378,
    radiantSparks = 3212,
    adventurer_crests = 3383,
    veteran_crests = 3341,
    champion_crests = 3343,
    hero_crests = 3345,
    myth_crests = 3347,
}

local SEASON2_CURRENCIES = {
    catalyst = 3465,
    tidalSparks = 3509,
    adventurer_crests = 3442,
    veteran_crests = 3443,
    champion_crests = 3444,
    hero_crests = 3445,
    myth_crests = 3446,
}

local SEASON1_TIER_SETS = {
    [1978] = true, -- Death Knight
    [1979] = true, -- Demon Hunter
    [1980] = true, -- Druid
    [1981] = true, -- Evoker
    [1982] = true, -- Hunter
    [1983] = true, -- Mage
    [1984] = true, -- Monk
    [1985] = true, -- Paladin
    [1986] = true, -- Priest
    [1987] = true, -- Rogue
    [1988] = true, -- Shaman
    [1989] = true, -- Warlock
    [1990] = true, -- Warrior
}

local SEASON2_TIER_SETS = {
    [2055] = true, -- Death Knight
    [2056] = true, -- Demon Hunter
    [2057] = true, -- Druid
    [2058] = true, -- Evoker
    [2059] = true, -- Hunter
    [2060] = true, -- Mage
    [2061] = true, -- Monk
    [2062] = true, -- Paladin
    [2063] = true, -- Priest
    [2064] = true, -- Rogue
    [2065] = true, -- Shaman
    [2066] = true, -- Warlock
    [2067] = true, -- Warrior
}

constants.TIER_SLOTS = {
    [1] = "Helm",
    [3] = "Shoulders",
    [5] = "Chest",
    [7] = "Pants",
    [10] = "Gloves",
}

local SEASON1_MAPS = {
    [525] = "Floodgate",
    [541] = "Stonecore",
    [542] = "Eco-Dome",
    [556] = "Saron",
    [557] = "Windrunner",
    [558] = "Magisters",
    [559] = "Xenas",
    [560] = "Maisara",
}

local SEASON2_MAPS = {
    [584] = "Vale",
    [585] = "Voidscar",
    [586] = "Den",
    [587] = "Murder",
    [588] = "Fangs",
}

constants.SEASON_DATA = {
    [1] = {
        tierLabel = "Tier (S1)",
        TIER_SETS = SEASON1_TIER_SETS,
        MAPS = SEASON1_MAPS,
        currencies = SEASON1_CURRENCIES,
    },
    [2] = {
        tierLabel = "Tier (S2)",
        TIER_SETS = SEASON2_TIER_SETS,
        MAPS = SEASON2_MAPS,
        currencies = SEASON2_CURRENCIES,
    },
}

local function ApplyActiveSeasonData()
    local activeSeason = constants.ACTIVE_SEASON_ID
    constants.SEASON_ID = activeSeason
    constants.SEASON = assert(constants.SEASON_DATA[activeSeason], "Missing active season data")
    constants.currencies = MergeKeyValues(BASE_CURRENCIES, constants.SEASON.currencies)
    constants.TIER_SETS = constants.SEASON.TIER_SETS
    constants.labels.TIER_SET = constants.SEASON.tierLabel
end

ApplyActiveSeasonData()

constants.VERSION = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addon, "Version")) or "12.1.0.67"

-- ------------------------------------------------------------
-- Utility helpers
-- ------------------------------------------------------------

local function true_numel(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end

local function FormatWholeNumber(value)
    local number = tonumber(value)
    if not number then return tostring(value or 0) end

    number = math.floor(number)
    local sign = number < 0 and "-" or ""
    local grouped = tostring(math.abs(number)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return sign .. grouped:gsub("^,", "")
end

local function GetCurrencyAmount(id)
    local info = C_CurrencyInfo.GetCurrencyInfo(id)
    return info and info.quantity or 0
end

local function PlayerHasCofferKeyGlue()
    local itemID = constants.COFFER_KEY_GLUE.ITEM_ID
    if type(PlayerHasToy) == "function" and PlayerHasToy(itemID) then
        return true
    end

    local spellID = constants.COFFER_KEY_GLUE.SPELL_ID
    if C_SpellBook and C_SpellBook.IsSpellKnown then
        local spellBank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player
        local isKnown = spellBank and C_SpellBook.IsSpellKnown(spellID, spellBank)
            or C_SpellBook.IsSpellKnown(spellID)
        if isKnown then
            return true
        end
    elseif type(IsPlayerSpell) == "function" and IsPlayerSpell(spellID) then
        return true
    end

    local itemCount
    if C_Item and C_Item.GetItemCount then
        itemCount = C_Item.GetItemCount(itemID)
    elseif type(GetItemCount) == "function" then
        itemCount = GetItemCount(itemID)
    end
    return (tonumber(itemCount) or 0) > 0
end

local function GetMonotonicTime()
    if GetTimePreciseSec then
        return GetTimePreciseSec()
    end
    return GetTime()
end

local function GetDungeonShortName(mapID)
    local seasonMaps = constants.SEASON and constants.SEASON.MAPS
    return (seasonMaps and seasonMaps[mapID]) or constants.DUNGEONS[mapID] or tostring(mapID)
end

local function GetWeeklyHighestKeystone(runHistory)
    local highestRun
    for _, run in ipairs(runHistory or {}) do
        local level = tonumber(run.level)
        -- GetRunHistory(false, true) is current-week data. Keep the explicit guard so
        -- previously stored mixed history can never surface an older run here.
        if run.thisWeek ~= false and level and level > 0
            and (not highestRun or level > highestRun.level) then
            highestRun = {
                level = level,
                mapID = tonumber(run.mapChallengeModeID),
            }
        end
    end
    return highestRun
end

-- ------------------------------------------------------------
-- Expansion migration (one-time per expansion bump)
-- ------------------------------------------------------------

function AltManager:GetCurrentExpansion()
    local _, _, _, interface = GetBuildInfo()
    if not interface then return nil end
    return math.floor(interface / 10000)
end

local function GetExpansionFromVersion(versionStr)
    if type(versionStr) ~= "string" then return nil end
    return tonumber(versionStr:match("^(%d+)"))
end

function AltManager:InferExpansionFromStoredData()
    local db = MyAltManagerDB
    if not db or not db.data then return nil end

    local lowest
    for _, alt_data in pairs(db.data) do
        local exp = GetExpansionFromVersion(alt_data and alt_data.version)
        if exp then
            if not lowest or exp < lowest then
                lowest = exp
            end
        end
    end
    return lowest
end

function AltManager:EnsureMeta()
    local db = MyAltManagerDB
    db.meta = db.meta or {}

    if db.meta.lastExpansionSeen == nil then
        local inferred = self:InferExpansionFromStoredData()
        db.meta.lastExpansionSeen = inferred or self:GetCurrentExpansion() or 0
    end

    return db.meta
end

function AltManager:MigrateDataSchema()
    local db = MyAltManagerDB
    if not db or not db.data then return 0 end

    local removed = 0
    for guid, charData in pairs(db.data) do
        local schema = tonumber(charData and charData.schema) or 0
        if schema < constants.DATA_SCHEMA then
            db.data[guid] = nil
            if db.config and db.config.openRows then
                db.config.openRows[guid] = nil
            end
            removed = removed + 1
        end
    end

    db.alts = true_numel(db.data)
    db.meta = db.meta or {}
    db.meta.dataSchema = constants.DATA_SCHEMA
    return removed
end

function AltManager:RunExpansionMigrationIfNeeded()
    local current = self:GetCurrentExpansion()
    if not current then return false end

    local meta = self:EnsureMeta()
    local last = tonumber(meta.lastExpansionSeen) or 0

    if last >= current then
        return false
    end

    -- One-time migration: pre-expansion cleanup wipe
    -- Preserve config so /alts min survives. Remove if you want a full nuke.
    local preservedConfig = nil
    if MyAltManagerDB and MyAltManagerDB.config then
        preservedConfig = MyAltManagerDB.config
    end

    MyAltManagerDB = self:InitDB()
    MyAltManagerDB.meta = MyAltManagerDB.meta or {}
    MyAltManagerDB.meta.lastExpansionSeen = current

    if preservedConfig then
        MyAltManagerDB.config = preservedConfig
    end

    print(("MyAltManager: Expansion migration %d -> %d complete. Saved data reset."):format(last, current))
    return true
end

-- ------------------------------------------------------------
-- Data collection gating / debounce (combat-safe)
-- ------------------------------------------------------------

function AltManager:CanCollectNow()
    if InCombatLockdown() or UnitAffectingCombat("player") then
        return false
    end
    if C_ChallengeMode.IsChallengeModeActive() then
        return false
    end
    if not IsLoggedIn() then
        return false
    end
    return true
end

function AltManager:LogCollectError(err)
    local message = tostring(err)
    if self._lastCollectError == message then
        return
    end

    self._lastCollectError = message
    print("MyAltManager: data collection failed: " .. message)
end

function AltManager:CollectAndStore()
    local ok, err = pcall(function()
        local data = self:CollectData()
        self:StoreData(data)
    end)

    if not ok then
        self:LogCollectError(err)
    end

    return ok
end

function AltManager:ScheduleCollect(reason)
    if not self.addon_loaded then return end
    if not self:CanCollectNow() then return end

    if self._collectTimer then
        return
    end

    local minInterval = constants.config.COLLECT_MIN_INTERVAL_SECONDS or 0
    local now = GetMonotonicTime()
    local delay = 0.5
    if self._lastCollectAt and minInterval > 0 then
        local elapsed = now - self._lastCollectAt
        if elapsed < minInterval then
            delay = math.max(delay, minInterval - elapsed)
        end
    end

    self._collectTimer = C_Timer.NewTimer(delay, function()
        self._collectTimer = nil
        if not self:CanCollectNow() then return end
        if self:CollectAndStore() then
            self._lastCollectAt = GetMonotonicTime()
            if self.main_frame and self.main_frame:IsShown() then
                self:RebuildUI()
            end
        end
    end)
end

function AltManager:RequestMythicPlusMetadata(force)
    if not IsLoggedIn() then
        return false
    end

    local minInterval = constants.config.MYTHICPLUS_METADATA_MIN_INTERVAL_SECONDS or 0
    local now = GetMonotonicTime()
    if not force and self._lastMPlusMetadataRequestAt and minInterval > 0 then
        local elapsed = now - self._lastMPlusMetadataRequestAt
        if elapsed < minInterval then
            return false
        end
    end

    self._lastMPlusMetadataRequestAt = now

    C_MythicPlus.RequestRewards()
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()

    return true
end

-- ------------------------------------------------------------
-- Slash commands
-- ------------------------------------------------------------

SLASH_ALTMANAGER1 = "/alts"

function AltManager:SetMinItemLevel(level)
    local db = MyAltManagerDB
    db.config = db.config or {}

    level = tonumber(level or 0) or 0
    if level < 0 then level = 0 end
    level = math.floor(level)

    db.config.MIN_ITEM_LEVEL = level
    constants.config.MIN_ITEM_LEVEL = level

    if self.addon_loaded and self.main_frame then
        self:RebuildUI()
    end

    print(("MyAltManager: MIN_ITEM_LEVEL set to %d"):format(level))
end

function MyAltManager_OnCompartmentClick()
    AltManager:ShowInterface()
end

function AltManager:LoadConfigFromDB()
    local db = MyAltManagerDB
    db.config = db.config or {}
    -- Visibility is no longer configurable. Discard legacy choices so every supported
    -- dashboard column, currency, weekly row, and drawer section is always available.
    db.visibility = nil

    if db.config.MIN_ITEM_LEVEL == nil then
        db.config.MIN_ITEM_LEVEL = 0
    end
    if db.config.MIN_LEVEL == nil then
        db.config.MIN_LEVEL = 80
    end
    local frameScale = tonumber(db.config.frame_scale) or constants.config.UI_SCALE
    frameScale = math.max(constants.config.UI_SCALE_MIN, math.min(constants.config.UI_SCALE_MAX, frameScale))
    frameScale = math.floor((frameScale * 20) + 0.5) / 20
    db.config.frame_scale = frameScale
    local trackerDefaults = constants.CURSE_SURGE_TRACKER
    if type(db.config.curse_surge_tracker_shown_by_character) ~= "table" then
        db.config.curse_surge_tracker_shown_by_character = {}
    end
    if db.config.curse_surge_tracker_width == nil then
        db.config.curse_surge_tracker_width = trackerDefaults.WIDTH
    end
    if db.config.curse_surge_tracker_height == nil then
        db.config.curse_surge_tracker_height = trackerDefaults.HEIGHT
    end
    if db.config.curse_surge_tracker_font_size == nil then
        db.config.curse_surge_tracker_font_size = trackerDefaults.FONT_SIZE
    end
    if db.config.curse_surge_tracker_background_opacity == nil then
        db.config.curse_surge_tracker_background_opacity = trackerDefaults.BACKGROUND_OPACITY
    end
    -- Opt-in: never announce unless the player has turned it on themselves.
    if db.config.curse_surge_announce == nil then
        db.config.curse_surge_announce = false
    end
    -- Saved so an already-announced surge is never announced a second time.
    if db.config.curse_surge_announced_start_epoch == nil then
        db.config.curse_surge_announced_start_epoch = 0
    end
    db.config.enable_drawer = nil
    db.config.drawer_config_version = nil
    -- Drawer expansion is temporary UI state and should not persist between openings.
    db.config.openRows = {}
    db.config.sort = nil
    constants.config.MIN_ITEM_LEVEL = tonumber(db.config.MIN_ITEM_LEVEL) or 0
    constants.config.MIN_LEVEL = tonumber(db.config.MIN_LEVEL) or 80
    constants.config.UI_SCALE = frameScale
end

function AltManager:RegisterSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("MyAltManager")
    self.settingsCategory = category

    local function RebuildIfNeeded()
        if AltManager.addon_loaded and AltManager.main_frame then
            AltManager:RebuildUI()
        end
    end

    -- Minimum Level slider (80-90, step 1, default 80)
    do
        local minLevelSetting = Settings.RegisterAddOnSetting(
            category, "MyAltManager_MinLevel", "MIN_LEVEL",
            MyAltManagerDB.config, Settings.VarType.Number,
            "Minimum Level", 80
        )
        local sliderOptions = Settings.CreateSliderOptions(80, 90, 1)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function() return "80" end)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function() return "90" end)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return tostring(math.floor(value)) end)
        Settings.CreateSlider(category, minLevelSetting, sliderOptions, "Only track characters at or above this level.")
        Settings.SetOnValueChangedCallback("MyAltManager_MinLevel", function(_, _, value)
            local v = math.floor(value)
            MyAltManagerDB.config.MIN_LEVEL = v
            constants.config.MIN_LEVEL = v
            RebuildIfNeeded()
        end)
    end

    -- Minimum Item Level slider (0-500, step 2, default 0)
    do
        local minIlvlSetting = Settings.RegisterAddOnSetting(
            category, "MyAltManager_MinItemLevel", "MIN_ITEM_LEVEL",
            MyAltManagerDB.config, Settings.VarType.Number,
            "Minimum Item Level", 0
        )
        local sliderOptions = Settings.CreateSliderOptions(0, 500, 2)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function() return "0" end)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function() return "500" end)
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return tostring(math.floor(value)) end)
        Settings.CreateSlider(category, minIlvlSetting, sliderOptions, "Only track characters at or above this item level.")
        Settings.SetOnValueChangedCallback("MyAltManager_MinItemLevel", function(_, _, value)
            local v = math.floor(value)
            MyAltManagerDB.config.MIN_ITEM_LEVEL = v
            constants.config.MIN_ITEM_LEVEL = v
            RebuildIfNeeded()
        end)
    end

    -- Curse Surge tracker appearance
    do
        local function RegisterTrackerSlider(variable, label, defaultValue, minimum, maximum, step, description)
            local variableName = "MyAltManager_" .. variable
            local setting = Settings.RegisterAddOnSetting(
                category, variableName, variable,
                MyAltManagerDB.config, Settings.VarType.Number,
                label, defaultValue
            )
            local sliderOptions = Settings.CreateSliderOptions(minimum, maximum, step)
            sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, function() return tostring(minimum) end)
            sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, function() return tostring(maximum) end)
            sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
                return tostring(math.floor(value))
            end)
            Settings.CreateSlider(category, setting, sliderOptions, description)
            Settings.SetOnValueChangedCallback(variableName, function(_, _, value)
                MyAltManagerDB.config[variable] = math.floor(value)
                AltManager:ApplyCurseSurgeTrackerSettings()
            end)
        end

        local trackerDefaults = constants.CURSE_SURGE_TRACKER
        RegisterTrackerSlider(
            "curse_surge_tracker_width", "Curse Surge Tracker Width",
            trackerDefaults.WIDTH, 220, 600, 10,
            "Set the width of the standalone Curse Surge timer."
        )
        RegisterTrackerSlider(
            "curse_surge_tracker_height", "Curse Surge Tracker Height",
            trackerDefaults.HEIGHT, 20, 60, 2,
            "Set the height of the standalone Curse Surge timer."
        )
        RegisterTrackerSlider(
            "curse_surge_tracker_font_size", "Curse Surge Tracker Text Size",
            trackerDefaults.FONT_SIZE, 9, 24, 1,
            "Set the font size of the standalone Curse Surge timer."
        )
        RegisterTrackerSlider(
            "curse_surge_tracker_background_opacity", "Curse Surge Tracker Background Opacity",
            trackerDefaults.BACKGROUND_OPACITY, 0, 100, 5,
            "Set the dark grey background opacity as a percentage."
        )
    end

    -- Curse Surge announcement, off unless the player opts in
    do
        local announceSetting = Settings.RegisterAddOnSetting(
            category, "MyAltManager_CurseSurgeAnnounce", "curse_surge_announce",
            MyAltManagerDB.config, Settings.VarType.Boolean,
            "Announce Next Curse Surge to Guild", false
        )
        Settings.CreateCheckbox(category, announceSetting,
            "Send one guild chat message five minutes before each Curse Surge, with its name, coordinates, and a clickable map pin. Held back until you are out of combat, sent once per surge account-wide, and printed to your own chat instead when you are not in a guild.")
        Settings.SetOnValueChangedCallback("MyAltManager_CurseSurgeAnnounce", function(_, _, value)
            MyAltManagerDB.config.curse_surge_announce = value and true or false
            AltManager:ApplyCurseSurgeAnnounceSetting()
        end)
    end

    Settings.RegisterAddOnCategory(category)
end

function SlashCmdList.ALTMANAGER(cmd, editbox)
    local rqst, arg = strsplit(" ", cmd)

    if rqst == "help" then
        print("MyAltManager help:")
        print("   \"/alts\" to open the UI.")
        print("   \"/alts export\" to export all alt data as Base64-encoded JSON.")
        print("   \"/alts settings\" to open the settings panel.")
        print("   \"/alts min <ilevel>\" to set minimum item level to store data (default 0).")
        print("   \"/alts purge\" to remove all stored data.")
        print("   \"/alts remove <name>\" to remove characters by name.")
    elseif rqst == "purge" then
        AltManager:Purge()
        print("MyAltManager: data wiped (manual purge).")
    elseif rqst == "remove" then
        AltManager:RemoveCharactersByName(arg)
    elseif rqst == "min" then
        AltManager:SetMinItemLevel(arg)
    elseif rqst == "export" then
        AltManager:ShowExport()
    elseif rqst == "settings" then
        if AltManager.settingsCategory then
            Settings.OpenToCategory(AltManager.settingsCategory:GetID())
        end
    else
        AltManager:ShowInterface()
    end
end

-- ------------------------------------------------------------
-- Main frame / events
-- ------------------------------------------------------------

do
    local main_frame = CreateFrame("Frame", "AltManagerFrame", UIParent)
    AltManager.main_frame = main_frame

    main_frame:SetFrameStrata("FULLSCREEN_DIALOG")
    main_frame:SetScale(constants.config.UI_SCALE)
    main_frame:ClearAllPoints()
    main_frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    main_frame:SetSize(constants.layout.FRAME_WIDTH, constants.layout.TITLE_HEIGHT + constants.layout.HEADER_HEIGHT + constants.layout.FOOTER_HEIGHT + 1)

    main_frame:RegisterEvent("ADDON_LOADED")
    main_frame:RegisterEvent("PLAYER_LOGIN")
    main_frame:RegisterEvent("QUEST_LOG_UPDATE")
    main_frame:RegisterEvent("QUEST_TURNED_IN")
    main_frame:RegisterEvent("BAG_UPDATE_DELAYED")
    main_frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    main_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    main_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    main_frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    main_frame:RegisterEvent("CHALLENGE_MODE_RESET")
    main_frame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
    main_frame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    main_frame:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE")
    main_frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    main_frame:RegisterEvent("EVENT_SCHEDULER_UPDATE")
    main_frame:RegisterEvent("TOYS_UPDATED")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "player")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    main_frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

    main_frame:SetScript("OnEvent", function(self, ...)
        local event, loadedOrType = ...

        if event == "ADDON_LOADED" then
            if addon == loadedOrType then
                AltManager:OnLoad()
            end
            return
        end

        if not AltManager.addon_loaded then
            return
        end

        if event == "PLAYER_LOGIN" then
            AltManager:OnLogin()
            return
        end

        -- Deferred for the same reason as the scheduler lookup below: this event is
        -- synchronous and its payload can be secret, so read the schedule off that path.
        if event == "EVENT_SCHEDULER_UPDATE" then
            C_Timer.After(0, function()
                AltManager:RefreshCurseSurgeEventCache()
                AltManager:UpdateFooterCurseSurge()
                AltManager:UpdateCurseSurgeTracker()
            end)
            return
        end

        if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
            local _, unit, _, spellID = ...
            AltManager:OnCofferKeyGlueSpellcastStart(unit, spellID)
            return
        end

        if event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_FAILED"
            or event == "UNIT_SPELLCAST_INTERRUPTED" then
            local _, unit, _, spellID = ...
            AltManager:OnCofferKeyGlueSpellcastEnded(unit, spellID)
            return
        end

        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local _, unit, _, spellID = ...
            AltManager:OnSpellcastSucceeded(unit, spellID)
            return
        end

        if event == "TOYS_UPDATED" then
            if AltManager.main_frame:IsShown() then
                AltManager:RebuildUI()
            end
            return
        end

        if event == "WEEKLY_REWARDS_UPDATE" then
            AltManager:ValidateReset()
            AltManager:ScheduleWeeklyResetCheck()
            AltManager:ScheduleCollect(event)
            return
        end

        if event == "QUEST_TURNED_IN" then
            if tonumber(loadedOrType) == constants.WEEKLY_META_QUEST.QUEST_ID then
                AltManager:MarkWeeklyMetaQuestCompleted()
            else
                AltManager:ScheduleCollect(event)
            end
            return
        end

        if event == "BAG_UPDATE_DELAYED"
            or event == "QUEST_LOG_UPDATE"
            or event == "CURRENCY_DISPLAY_UPDATE"
            or event == "CHALLENGE_MODE_MAPS_UPDATE"
            or event == "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE"
            or event == "PLAYER_EQUIPMENT_CHANGED" then
            AltManager:ScheduleCollect(event)
            return
        end

        if event == "CHALLENGE_MODE_COMPLETED"
            or event == "CHALLENGE_MODE_RESET" then
            AltManager:RequestMythicPlusMetadata()
            AltManager:ScheduleCollect(event)
            return
        end

        if event == "PLAYER_REGEN_DISABLED" then
            if AltManager.main_frame:IsShown() then
                AltManager:RebuildUI()
            end
            return
        end

        if event == "PLAYER_REGEN_ENABLED" then
            -- Release an announcement that was held back while the player was fighting.
            AltManager:CheckCurseSurgeAnnouncement()
            if AltManager.main_frame:IsShown() then
                AltManager:RebuildUI()
            else
                AltManager:UpdateCofferKeyGlueButton()
            end
            AltManager:ScheduleCollect(event)
            return
        end
    end)

    if type(UISpecialFrames) == "table" then
        tinsert(UISpecialFrames, "AltManagerFrame")
    end

    main_frame:Hide()
end

-- ------------------------------------------------------------
-- DB and sizing
-- ------------------------------------------------------------

function AltManager:InitDB()
    local t = {}
    t.alts = 0
    t.data = {}
    t.config = {
        MIN_ITEM_LEVEL = 0,
        MIN_LEVEL = 80,
        openRows = {},
        frame_scale = constants.config.UI_SCALE,
        curse_surge_tracker_shown_by_character = {},
        curse_surge_tracker_width = constants.CURSE_SURGE_TRACKER.WIDTH,
        curse_surge_tracker_height = constants.CURSE_SURGE_TRACKER.HEIGHT,
        curse_surge_tracker_font_size = constants.CURSE_SURGE_TRACKER.FONT_SIZE,
        curse_surge_tracker_background_opacity = constants.CURSE_SURGE_TRACKER.BACKGROUND_OPACITY,
        curse_surge_announce = false,
        curse_surge_announced_start_epoch = 0,
    }
    t.meta = {}
    t.hiddenTrove = {}
    t.weeklyMetaQuestCompletions = {}
    return t
end

-- Kept as a single policy point for the layout/rendering call sites: supported content
-- is always visible and legacy SavedVariables can no longer suppress it.
function AltManager:IsRowVisible()
    return true
end

function AltManager:OnLogin()
    self:ValidateReset()
    self:ScheduleWeeklyResetCheck()
    self:RequestMythicPlusMetadata()
    self:PrimeCurseSurgeEventData()
    self:ApplyCurseSurgeAnnounceSetting()
    if self:CollectAndStore() then
        self._lastCollectAt = GetMonotonicTime()
    end

    self:RebuildUI()
end

function AltManager:OnLoad()
    self.main_frame:UnregisterEvent("ADDON_LOADED")

    MyAltManagerDB = MyAltManagerDB or self:InitDB()
    ApplyActiveSeasonData()

    -- One-time per-expansion migration (pre-expansion cleanup wipe)
    if self:RunExpansionMigrationIfNeeded() then
        self:LoadConfigFromDB()
        self:MigrateDataSchema()
        self:InitializeFrame()
        self:RegisterSettings()
        self.addon_loaded = true
        return
    end

    self:LoadConfigFromDB()
    self:MigrateDataSchema()

    if MyAltManagerDB.alts ~= true_numel(MyAltManagerDB.data) then
        MyAltManagerDB.alts = true_numel(MyAltManagerDB.data)
    end

    self:InitializeFrame()
    self:RegisterSettings()
    self.addon_loaded = true

    -- Request M+ metadata at load-time, not in CollectData.
    self:RequestMythicPlusMetadata()
end

local function CreateEmptyVaultTrack(thresholds)
    local slots = {}
    for i = 1, 3 do
        slots[i] = {
            progress = 0,
            threshold = thresholds[i],
            earned = false,
            ilvl = nil,
            activityID = nil,
            raidString = nil,
        }
    end
    return slots
end

local function CreateResetWeeklies()
    return {
        { key = "weeklyMetaQuest", status = "notstarted" },
        { key = "curseSurges", status = "notstarted" },
        { key = "purgingTheVaults", status = "notstarted" },
        { key = "saththerilSoiree", status = "notstarted" },
        { key = "abundantOfferings", status = "notstarted" },
        { key = "legendsOfTheHaranir", status = "notstarted" },
        { key = "stormarianAssault", status = "notstarted" },
        { key = "midnightWorldTour", status = "notstarted" },
        { key = "hiddenTrove", status = "notstarted" },
        { key = "nightmarishTask", status = "notstarted" },
        { key = "worldBoss", status = "notstarted" },
    }
end

-- Hidden Trove completions live outside `db.data` because StoreData replaces a character's whole
-- table on every collect, and the trove can be opened while collection is blocked (in combat, or
-- mid-delve). Keyed by GUID so each character carries its own weekly lockout.
function AltManager:EnsureHiddenTroveStore()
    local db = MyAltManagerDB
    if not db then return nil end

    db.hiddenTrove = db.hiddenTrove or {}
    return db.hiddenTrove
end

local function GetHiddenTroveExpiry()
    -- Fall back to a full week if the client has not reported the reset yet; ValidateReset still
    -- clears the record when the character's own weekly window rolls over.
    return AltManager:GetNextWeeklyResetTime() or (time() + 7 * 24 * 60 * 60)
end

function AltManager:IsHiddenTroveCompleted(guid)
    local store = self:EnsureHiddenTroveStore()
    if not store or not guid then return false end

    local record = store[guid]
    if not record then return false end

    local expires = tonumber(record.expires) or 0
    if expires > 0 and time() >= expires then
        store[guid] = nil
        return false
    end

    return true
end

function AltManager:MarkHiddenTroveCompleted(guid)
    local store = self:EnsureHiddenTroveStore()
    guid = guid or UnitGUID("player")
    if not store or not guid then return false end

    local alreadyDone = self:IsHiddenTroveCompleted(guid)
    store[guid] = {
        completedAt = time(),
        expires = GetHiddenTroveExpiry(),
    }

    if alreadyDone then
        return false
    end

    self:ScheduleCollect("HIDDEN_TROVE_OPENED")
    return true
end

function AltManager:EnsureWeeklyMetaQuestCompletionStore()
    local db = MyAltManagerDB
    if not db then return nil end

    db.weeklyMetaQuestCompletions = db.weeklyMetaQuestCompletions or {}
    return db.weeklyMetaQuestCompletions
end

function AltManager:GetWeeklyMetaQuestCompletedAt(guid)
    guid = guid or UnitGUID("player")
    if not guid then return nil end

    local store = self:EnsureWeeklyMetaQuestCompletionStore()
    local storedAt = tonumber(store and store[guid])
    local charData = MyAltManagerDB and MyAltManagerDB.data and MyAltManagerDB.data[guid]
    local charAt = tonumber(charData and charData.weeklyMetaQuestCompletedAt)

    if storedAt and charAt then
        return math.max(storedAt, charAt)
    end
    return storedAt or charAt
end


function AltManager:MarkWeeklyMetaQuestCompleted(guid)
    guid = guid or UnitGUID("player")
    local store = self:EnsureWeeklyMetaQuestCompletionStore()
    if not guid or not store then return false end

    local completedAt = time()
    store[guid] = completedAt

    local charData = MyAltManagerDB.data and MyAltManagerDB.data[guid]
    if charData then
        charData.weeklyMetaQuestCompletedAt = completedAt
    end

    self:ScheduleCollect("WEEKLY_META_QUEST_TURNED_IN")
    return true
end

function AltManager:OnSpellcastSucceeded(unit, spellID)
    if unit ~= "player" then return end

    spellID = tonumber(spellID)
    if not spellID then return end

    if spellID == constants.COFFER_KEY_GLUE.SPELL_ID then
        self:StopCofferKeyGlueCastDisplay()
        self:ScheduleCollect("COFFER_KEY_GLUE_USED")
        return
    end

    for _, trackedID in ipairs(constants.HIDDEN_TROVE.SPELL_IDS) do
        if spellID == trackedID then
            self:MarkHiddenTroveCompleted()
            return
        end
    end
end

function AltManager:ValidateReset()
    local db = MyAltManagerDB
    if not db or not db.data then return 0 end

    local now = time()
    local nextReset = self:GetNextWeeklyResetTime()
    if not nextReset or nextReset <= now then
        nextReset = now + constants.WEEK_SECONDS
    end
    local resetCount = 0
    for _, char_table in pairs(db.data) do
        local expiry = tonumber(char_table.expires) or 0
        if expiry <= 0 or now >= expiry then
            char_table.runHistory = nil
            if char_table.mplus then
                char_table.mplus.keyMapID = nil
                char_table.mplus.keyLevel = nil
            end
            char_table.vault = {
                raid = CreateEmptyVaultTrack({ 2, 4, 6 }),
                dungeon = CreateEmptyVaultTrack({ 1, 4, 8 }),
                world = CreateEmptyVaultTrack({ 2, 4, 8 }),
            }
            char_table.weeklies = CreateResetWeeklies()
            char_table.expires = nextReset
            char_table.weeklyCofferKeysCollected = 0
            if type(char_table.cofferKeyShards) == "table" then
                char_table.cofferKeyShards.earnedThisWeek = 0
            end
            resetCount = resetCount + 1
        end
    end

    local hiddenTroveStore = self:EnsureHiddenTroveStore()
    if hiddenTroveStore then
        for guid, record in pairs(hiddenTroveStore) do
            local expires = tonumber(record and record.expires) or 0
            if expires <= 0 or now >= expires then
                hiddenTroveStore[guid] = nil
            end
        end
    end
    return resetCount
end

function AltManager:ScheduleWeeklyResetCheck()
    if self._weeklyResetTimer then
        self._weeklyResetTimer:Cancel()
        self._weeklyResetTimer = nil
    end

    local seconds = tonumber(C_DateAndTime.GetSecondsUntilWeeklyReset())
    local delay = seconds and seconds > 0 and math.min(seconds + 1, 60 * 60) or 60
    self._weeklyResetTimer = C_Timer.NewTimer(delay, function()
        AltManager._weeklyResetTimer = nil
        local resetCount = AltManager:ValidateReset()
        if resetCount > 0 and AltManager.main_frame and AltManager.main_frame:IsShown() then
            AltManager:RebuildUI()
        end
        AltManager:ScheduleWeeklyResetCheck()
    end)
end

function AltManager:Purge()
    MyAltManagerDB = MyAltManagerDB or self:InitDB()
    MyAltManagerDB.data = {}
    MyAltManagerDB.alts = 0
    MyAltManagerDB.weeklyMetaQuestCompletions = {}
    MyAltManagerDB.config = MyAltManagerDB.config or {}
    MyAltManagerDB.config.openRows = {}
    self:LoadConfigFromDB()
    self:RebuildUI()
end

function AltManager:RemoveCharactersByName(name)
    local db = MyAltManagerDB
    local indices = {}

    for guid, data in pairs(db.data) do
        if db.data[guid].name == name then
            indices[#indices + 1] = guid
        end
    end

    for i = 1, #indices do
        db.data[indices[i]] = nil
        if db.weeklyMetaQuestCompletions then
            db.weeklyMetaQuestCompletions[indices[i]] = nil
        end
        if db.config and db.config.openRows then
            db.config.openRows[indices[i]] = nil
        end
    end
    db.alts = true_numel(db.data)

    print("Found " .. (#indices) .. " characters by the name of " .. name)
    self:RebuildUI()
end

function AltManager:RemoveCharacterByGuid(index)
    local db = MyAltManagerDB
    if db.data[index] == nil then return end

    local delete = function()
        if db.data[index] == nil then return end
        db.data[index] = nil
        if db.weeklyMetaQuestCompletions then
            db.weeklyMetaQuestCompletions[index] = nil
        end
        db.alts = true_numel(db.data)
        if db.config and db.config.openRows then
            db.config.openRows[index] = nil
        end
        GameTooltip:Hide()
        self:RebuildUI()
    end

    delete()
end

-- ------------------------------------------------------------
-- Store/Collect (unchanged tracking logic; gated by StoreData + ScheduleCollect)
-- ------------------------------------------------------------

function AltManager:StoreData(data)
    if not data or not data.guid then
        return
    end

    if UnitLevel("player") < constants.config.MIN_LEVEL then
        return
    end

    local db = MyAltManagerDB
    db.config = db.config or {}

    local minIlvl = tonumber(db.config.MIN_ITEM_LEVEL)
    if minIlvl == nil then
        minIlvl = constants.config.MIN_ITEM_LEVEL or 0
        db.config.MIN_ITEM_LEVEL = minIlvl
    end
    constants.config.MIN_ITEM_LEVEL = minIlvl

    local i = data.ilevel
    if not i then
        local _, currentItemLevel = GetAverageItemLevel()
        i = currentItemLevel
    end
    if not i or i == 0 then return end
    if i < minIlvl then return end

    db.data = db.data or {}
    local guid = data.guid

    local update = (db.data[guid] ~= nil)
    if not update then
        db.data[guid] = data
        db.alts = (tonumber(db.alts) or 0) + 1
    else
        db.data[guid] = data
    end
end

local JSON_ARRAY_KEYS = {
    adventurer = true,
    champion = true,
    dungeon = true,
    hero = true,
    myth = true,
    raid = true,
    runHistory = true,
    sparks = true,
    tierSlots = true,
    veteran = true,
    weeklies = true,
    world = true,
}

local JSON_ESCAPE_CHARACTERS = {
    ['"'] = '\\"',
    ['\\'] = '\\\\',
    ['\b'] = '\\b',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
    ['\r'] = '\\r',
    ['\t'] = '\\t',
}

local function EncodeJsonString(value)
    return '"' .. value:gsub('["\\%z\1-\31]', function(character)
        return JSON_ESCAPE_CHARACTERS[character]
            or string.format("\\u%04x", string.byte(character))
    end) .. '"'
end

local function IsJsonArray(value, parentKey)
    local count = 0
    local maximum = 0
    for key in pairs(value) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end
        count = count + 1
        maximum = math.max(maximum, key)
    end

    if count == 0 then
        return JSON_ARRAY_KEYS[parentKey] == true
    end
    return maximum == count
end

local function EncodeJsonValue(value, parentKey, ancestors)
    local valueType = type(value)
    if valueType == "nil" then
        return "null"
    elseif valueType == "boolean" then
        return value and "true" or "false"
    elseif valueType == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            return "null"
        end
        return tostring(value)
    elseif valueType == "string" then
        return EncodeJsonString(value)
    elseif valueType ~= "table" then
        error("cannot export Lua value of type " .. valueType)
    end

    if ancestors[value] then
        error("cannot export a cyclic table")
    end
    ancestors[value] = true

    local encoded = {}
    if IsJsonArray(value, parentKey) then
        for index = 1, #value do
            encoded[index] = EncodeJsonValue(value[index], nil, ancestors)
        end
        ancestors[value] = nil
        return "[" .. table.concat(encoded, ",") .. "]"
    end

    local keys = {}
    for key in pairs(value) do
        local keyType = type(key)
        if keyType ~= "string" and keyType ~= "number" then
            error("cannot export table key of type " .. keyType)
        end
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)

    for _, key in ipairs(keys) do
        encoded[#encoded + 1] = EncodeJsonString(tostring(key))
            .. ":" .. EncodeJsonValue(value[key], tostring(key), ancestors)
    end
    ancestors[value] = nil
    return "{" .. table.concat(encoded, ",") .. "}"
end

local BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function EncodeBase64(value)
    local encoded = {}
    for index = 1, #value, 3 do
        local first = string.byte(value, index)
        local second = string.byte(value, index + 1)
        local third = string.byte(value, index + 2)
        local combined = first * 65536 + (second or 0) * 256 + (third or 0)

        encoded[#encoded + 1] = BASE64_ALPHABET:sub(math.floor(combined / 262144) % 64 + 1, math.floor(combined / 262144) % 64 + 1)
        encoded[#encoded + 1] = BASE64_ALPHABET:sub(math.floor(combined / 4096) % 64 + 1, math.floor(combined / 4096) % 64 + 1)
        encoded[#encoded + 1] = second
            and BASE64_ALPHABET:sub(math.floor(combined / 64) % 64 + 1, math.floor(combined / 64) % 64 + 1)
            or "="
        encoded[#encoded + 1] = third
            and BASE64_ALPHABET:sub(combined % 64 + 1, combined % 64 + 1)
            or "="
    end
    return table.concat(encoded)
end

function AltManager:BuildExportPayload()
    local data = MyAltManagerDB and MyAltManagerDB.data or {}
    local weeklyResetAt = self:GetNextWeeklyResetTime()
    return {
        formatVersion = 1,
        addonVersion = constants.VERSION,
        exportedAt = time(),
        weeklyResetAt = weeklyResetAt,
        lastWeeklyResetAt = weeklyResetAt and (weeklyResetAt - constants.WEEK_SECONDS)
            or self:GetLastWeeklyResetTime(),
        characterCount = true_numel(data),
        characters = data,
    }
end

function AltManager:BuildExportJson()
    return EncodeJsonValue(self:BuildExportPayload(), nil, {})
end

function AltManager:BuildExportString()
    return EncodeBase64(self:BuildExportJson())
end

local function CollectVaultTrack(activityType, fallbackThresholds, useRaidStringFallback)
    local activities = C_WeeklyRewards.GetActivities(activityType) or {}
    local slots = {}

    for i = 1, 3 do
        local activity = activities[i]
        local threshold = (activity and activity.threshold) or fallbackThresholds[i] or 0
        if type(threshold) ~= "number" or threshold <= 0 then
            threshold = fallbackThresholds[i] or 0
        end

        local progress = tonumber(activity and activity.progress) or 0
        local earned = activity ~= nil and threshold > 0 and progress >= threshold
        local ilvl
        if earned and activity.id then
            local link = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
            ilvl = link and C_Item.GetDetailedItemLevelInfo(link) or nil
        end

        slots[i] = {
            progress = progress,
            threshold = threshold,
            earned = earned,
            ilvl = ilvl,
            activityID = activity and activity.id or nil,
            raidString = (useRaidStringFallback and activity and activity.raidString) or nil,
        }
    end

    return slots
end

function AltManager:CollectData()
    local _, i = GetAverageItemLevel()
    if not i or i == 0 then return end

    if UnitLevel("player") < constants.config.MIN_LEVEL then return end

    local name = UnitName("player")
    local _, class = UnitClass("player")

    local guid = UnitGUID("player")
    local weeklyMetaQuestCompletedAt = self:GetWeeklyMetaQuestCompletedAt(guid)

    local runHistory = C_MythicPlus.GetRunHistory(false, true) or {}

    local function QuestSetStatus(questIDs)
        local inProgress = false
        for _, questID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                return "complete"
            elseif C_QuestLog.IsOnQuest(questID) then
                inProgress = true
            end
        end
        return inProgress and "inprogress" or "notstarted"
    end

    local function GetQuestObjectiveProgress(questID, expectedRequired)
        local objectives = C_QuestLog.GetQuestObjectives(questID) or {}
        local fallback
        for _, objective in ipairs(objectives) do
            local progress = tonumber(objective.numFulfilled)
            local required = tonumber(objective.numRequired)
            if progress and required and required > 0 then
                local values = { progress = progress, required = required }
                if required == expectedRequired then
                    return values
                end
                fallback = fallback or values
            end
        end
        return fallback
    end

    local function GetCountQuestStatus(questID, expectedRequired)
        local weekly = { status = QuestSetStatus({ questID }) }
        if weekly.status ~= "inprogress" then return weekly end

        local objective = GetQuestObjectiveProgress(questID, expectedRequired)
        if objective then
            weekly.progressType = "count"
            weekly.progress = objective.progress
            weekly.required = objective.required
        end
        return weekly
    end

    local function GetPercentageQuestStatus(questID)
        local weekly = { status = QuestSetStatus({ questID }) }
        if weekly.status ~= "inprogress" then return weekly end

        local percentage
        if type(GetQuestProgressBarPercent) == "function" then
            percentage = tonumber(GetQuestProgressBarPercent(questID))
        end
        if not percentage then
            local objective = GetQuestObjectiveProgress(questID, 100)
            if objective then
                percentage = (objective.progress / objective.required) * 100
            end
        end
        if percentage then
            weekly.progressType = "percent"
            weekly.progress = math.floor(math.max(0, math.min(100, percentage)) + 0.5)
        end
        return weekly
    end

    local function GetMidnightWorldTourStatus()
        local questID = 95245
        local requiredCount = 4
        local weekly = { status = QuestSetStatus({ questID }) }
        if weekly.status ~= "inprogress" then return weekly end

        local completed = 0
        local tracked = 0
        for _, objective in ipairs(C_QuestLog.GetQuestObjectives(questID) or {}) do
            local normalizedText = tostring(objective.text or ""):lower():gsub("[^%a]", "")
            local isOptional = normalizedText:find("lorthemar", 1, true) ~= nil
            if not isOptional then
                tracked = tracked + 1
                local progress = tonumber(objective.numFulfilled) or 0
                local required = tonumber(objective.numRequired) or 0
                if objective.finished or (required > 0 and progress >= required) then
                    completed = completed + 1
                end
            end
        end

        -- Only report a count when the optional objective was successfully excluded
        -- (or Blizzard omitted it) and exactly four required objectives remain.
        if tracked == requiredCount then
            weekly.progressType = "count"
            weekly.progress = completed
            weekly.required = requiredCount
        end
        return weekly
    end

    local function checkWeeklyMetaQuestStatus()
        local lastResetAt = self:GetLastWeeklyResetTime()
        if weeklyMetaQuestCompletedAt
            and (not lastResetAt or weeklyMetaQuestCompletedAt >= lastResetAt) then
            return "complete"
        end

        if C_QuestLog.IsOnQuest(constants.WEEKLY_META_QUEST.QUEST_ID) then
            return "inprogress"
        end
        return "notstarted"
    end

    local function checkSaththerilSoireeStatus()
        return QuestSetStatus({ 90575, 90576, 90574, 90573 })
    end

    local function checkWorldBossStatus()
        local db2 = MyAltManagerDB and MyAltManagerDB.data
        -- Weekly world-boss completion can fall out of quest flags after login, so preserve a stored complete state until reset.
        local stored = db2 and guid and db2[guid] and db2[guid].weeklies
        for _, weekly in ipairs(stored or {}) do
            if weekly.key == "worldBoss" and weekly.status == "complete" then
                return "complete"
            end
        end

        -- 97128 (Lair: Nymrissa Wavecaller) is per-character rather than account-wide, so each alt must kill it themselves.
        -- Retired account-wide world boss quests, kept for reference: 92034 (Thorm'belan), 92636, 92560, 92123 (Cragpine).
        return QuestSetStatus({ 97128 })
    end

    local function checkWeeklyCofferKeysCollected()
        local cofferKeyQuestIds = { 84736, 84737, 84738, 84739 }
        local cofferKeysObtained = 0
        for _, questID in ipairs(cofferKeyQuestIds) do
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                cofferKeysObtained = cofferKeysObtained + 1
            end
        end
        return cofferKeysObtained
    end

    local function GetRollingCurrencyValues(currencyID)
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if not info then return 0, 0 end

        local quantity = tonumber(info.quantity) or 0
        local totalEarned = tonumber(info.totalEarned) or quantity
        local maxQuantity = tonumber(info.maxQuantity) or 0
        if info.useTotalEarnedForMaxQty then
            if maxQuantity <= 0 then
                maxQuantity = totalEarned
            end
            return totalEarned, maxQuantity, totalEarned, maxQuantity
        end

        local spent = math.max(0, totalEarned - quantity)
        if maxQuantity <= 0 then
            maxQuantity = quantity
        end

        local rollingMax = math.max(quantity, maxQuantity - spent)
        return quantity, rollingMax, totalEarned, maxQuantity
    end

    local function GetWeeklyCurrencyValues(currencyID)
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if not info then return 0, 0, 0 end

        local available = tonumber(info.quantity) or 0
        local earnedThisWeek = tonumber(info.quantityEarnedThisWeek) or available
        local weeklyMaximum = tonumber(info.maxWeeklyQuantity) or 0
        return available, earnedThisWeek, weeklyMaximum
    end

    local ownedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()

    local weeklyMetaQuest = checkWeeklyMetaQuestStatus()
    local curseSurges = GetCountQuestStatus(96995, 3)
    local worldBoss = checkWorldBossStatus()

    local abundantOfferings = QuestSetStatus({ 89507 })
    local stormarianAssault = QuestSetStatus({ 94581 })
    local legendsOfTheHaranir = QuestSetStatus({ 89268 })
    local saththerilSoiree = checkSaththerilSoireeStatus()
    local midnightWorldTour = GetMidnightWorldTourStatus()
    -- Tracked from the trove's opening cast (see OnSpellcastSucceeded), not a quest ID.
    local hiddenTrove = self:IsHiddenTroveCompleted(guid) and "complete" or "notstarted"
    local nightmarishTask = GetCountQuestStatus(94446, 3)
    local purgingTheVaults = GetPercentageQuestStatus(95520)

    local weeklyCofferKeysCollected = checkWeeklyCofferKeysCollected()

    local ilevel = i

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(constants.currencies.conquest)
    local total_conquest_earned = conquestInfo and conquestInfo.totalEarned or 0
    local conquest = conquestInfo and conquestInfo.quantity or 0

    local honor = GetCurrencyAmount(constants.currencies.honor)
    local bloody_tokens = GetCurrencyAmount(constants.currencies.bloodyTokens)

    local adventurerCur, adventurerMax = GetRollingCurrencyValues(constants.currencies.adventurer_crests)
    local veteranCur, veteranMax = GetRollingCurrencyValues(constants.currencies.veteran_crests)
    local championCur, championMax = GetRollingCurrencyValues(constants.currencies.champion_crests)
    local heroCur, heroMax = GetRollingCurrencyValues(constants.currencies.hero_crests)
    local mythCur, mythMax = GetRollingCurrencyValues(constants.currencies.myth_crests)
    local sparksCur, sparksMax = GetRollingCurrencyValues(constants.currencies.tidalSparks)
    local undercoin = GetCurrencyAmount(constants.currencies.undercoin) or 0
    local anglerPearls = GetCurrencyAmount(constants.currencies.anglerPearls) or 0
    local voidlightMarl = GetCurrencyAmount(constants.currencies.voidlightMarl) or 0
    local restored_coffer_keys = GetCurrencyAmount(constants.currencies.restored_coffer_keys) or 0
    local cofferKeyShardsAvailable, cofferKeyShardsEarned, cofferKeyShardsWeeklyMax =
        GetWeeklyCurrencyValues(constants.currencies.cofferKeyShards)
    local shardOfDundun = GetCurrencyAmount(constants.currencies.shardOfDundun) or 0
    local remnantOfAnguish = GetCurrencyAmount(constants.currencies.remnantOfAnguish) or 0
    local unalloyedAbundance = GetCurrencyAmount(constants.currencies.unalloyedAbundance) or 0
    local nebulousVoidcore = GetCurrencyAmount(constants.currencies.nebulousVoidcore) or 0
    local untaintedManaCrystal = GetCurrencyAmount(constants.currencies.untaintedManaCrystal) or 0
    local fieldAccolade = GetCurrencyAmount(constants.currencies.fieldAccolade) or 0
    local luminousDust = GetCurrencyAmount(constants.currencies.luminousDust) or 0
    local brimmingArcana = GetCurrencyAmount(constants.currencies.brimmingArcana) or 0

    local catalystInfo = C_CurrencyInfo.GetCurrencyInfo(constants.currencies.catalyst)
    local catalystCharges = catalystInfo and catalystInfo.quantity or 0
    local catalystChargesMax = catalystInfo and catalystInfo.maxQuantity or 0

    local tierPieces, tierSlots = self:GetTierBonuses()
    local mplus = self:GetOverallDungeonScore()
    mplus.keyMapID = ownedKeystoneChallengeMapID
    mplus.keyLevel = ownedKeystoneLevel

    local char_table = {
        schema = constants.DATA_SCHEMA,
        seasonID = constants.SEASON_ID,
        guid = guid,
        name = name,
        class = class,
        ilevel = math.floor(ilevel),
        charLevel = UnitLevel("player"),
        realmName = GetRealmName(),
        tierPieces = tierPieces,
        tierSlots = tierSlots,
        catalyst = {
            current = tonumber(catalystCharges) or 0,
            max = tonumber(catalystChargesMax) or 0,
        },
        mplus = mplus,
        vault = {
            raid = CollectVaultTrack(Enum.WeeklyRewardChestThresholdType.Raid, { 2, 4, 6 }, true),
            dungeon = CollectVaultTrack(Enum.WeeklyRewardChestThresholdType.Activities, { 1, 4, 8 }, false),
            world = CollectVaultTrack(Enum.WeeklyRewardChestThresholdType.World, { 2, 4, 8 }, false),
        },
        season = {
            sparks = { sparksCur, sparksMax },
            adventurer = { adventurerCur, adventurerMax },
            veteran = { veteranCur, veteranMax },
            champion = { championCur, championMax },
            hero = { heroCur, heroMax },
            myth = { mythCur, mythMax },
        },
        weeklies = {
            { key = "weeklyMetaQuest", status = weeklyMetaQuest },
            {
                key = "curseSurges",
                status = curseSurges.status,
                progressType = curseSurges.progressType,
                progress = curseSurges.progress,
                required = curseSurges.required,
            },
            {
                key = "purgingTheVaults",
                status = purgingTheVaults.status,
                progressType = purgingTheVaults.progressType,
                progress = purgingTheVaults.progress,
            },
            { key = "saththerilSoiree", status = saththerilSoiree },
            { key = "abundantOfferings", status = abundantOfferings },
            { key = "legendsOfTheHaranir", status = legendsOfTheHaranir },
            { key = "stormarianAssault", status = stormarianAssault },
            {
                key = "midnightWorldTour",
                status = midnightWorldTour.status,
                progressType = midnightWorldTour.progressType,
                progress = midnightWorldTour.progress,
                required = midnightWorldTour.required,
            },
            { key = "hiddenTrove", status = hiddenTrove },
            {
                key = "nightmarishTask",
                status = nightmarishTask.status,
                progressType = nightmarishTask.progressType,
                progress = nightmarishTask.progress,
                required = nightmarishTask.required,
            },
            { key = "worldBoss", status = worldBoss },
        },
        pvp = {
            honor = tonumber(honor) or 0,
            conquest = tonumber(conquest) or 0,
            conquestEarned = tonumber(total_conquest_earned) or 0,
            bloodyTokens = tonumber(bloody_tokens) or 0,
        },
        undercoin = undercoin,
        anglerPearls = anglerPearls,
        voidlightMarl = voidlightMarl,
        restored_coffer_keys = restored_coffer_keys,
        cofferKeyShards = {
            available = cofferKeyShardsAvailable,
            earnedThisWeek = cofferKeyShardsEarned,
            weeklyMaximum = cofferKeyShardsWeeklyMax,
        },
        shardOfDundun = shardOfDundun,
        remnantOfAnguish = remnantOfAnguish,
        unalloyedAbundance = unalloyedAbundance,
        nebulousVoidcore = nebulousVoidcore,
        untaintedManaCrystal = untaintedManaCrystal,
        fieldAccolade = fieldAccolade,
        luminousDust = luminousDust,
        brimmingArcana = brimmingArcana,
        weeklyCofferKeysCollected = weeklyCofferKeysCollected,
        weeklyMetaQuestCompletedAt = weeklyMetaQuestCompletedAt,
        runHistory = runHistory,
        version = constants.VERSION,
        expires = self:GetNextWeeklyResetTime(),
        dataObtained = time(),
    }

    return char_table
end

-- ------------------------------------------------------------
-- Tier, score, weekly rewards
-- ------------------------------------------------------------

function AltManager:RequestTierItemRescan(itemID)
    if not itemID or not Item or not Item.CreateFromItemID then
        return
    end

    self._pendingTierItemLoads = self._pendingTierItemLoads or {}
    if self._pendingTierItemLoads[itemID] then
        return
    end

    self._pendingTierItemLoads[itemID] = true
    Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
        self._pendingTierItemLoads[itemID] = nil
        self:ScheduleCollect("TIER_ITEM_LOADED")
    end)
end

function AltManager:GetTierBonuses()
    local tierCount = 0
    local tierItems = {}

    for slotId in pairs(constants.TIER_SLOTS) do
        local invItem = GetInventoryItemID("player", slotId)
        if invItem then
            local setId = select(16, C_Item.GetItemInfo(invItem))
            if setId and constants.TIER_SETS[setId] then
                tierItems["equip:" .. slotId] = constants.TIER_SLOTS[slotId]
            elseif not setId then
                self:RequestTierItemRescan(invItem)
            end
        end
    end

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(container)
        for slot = 1, slots do
            local slotItem = C_Container.GetContainerItemInfo(container, slot)
            if slotItem ~= nil then
                local setId = select(16, C_Item.GetItemInfo(slotItem.itemID))
                if setId and constants.TIER_SETS[setId] then
                    tierItems[("bag:%d:%d"):format(container, slot)] = "Stored tier piece"
                elseif not setId then
                    self:RequestTierItemRescan(slotItem.itemID)
                end
            end
        end
    end

    local tierSlots = {}
    for _, slotName in pairs(tierItems) do
        tierCount = tierCount + 1
        tierSlots[#tierSlots + 1] = slotName
    end

    tierCount = math.min(tierCount, 5)
    table.sort(tierSlots)
    while #tierSlots > tierCount do
        table.remove(tierSlots)
    end
    return tierCount, tierSlots
end

function AltManager:GetOverallDungeonScore()
    local overallDungeonScore = C_ChallengeMode.GetOverallDungeonScore() or 0
    local color = C_ChallengeMode.GetDungeonScoreRarityColor(overallDungeonScore) or HIGHLIGHT_FONT_COLOR
    return {
        score = tonumber(overallDungeonScore) or 0,
        r = color.r or 1,
        g = color.g or 1,
        b = color.b or 1,
    }
end

-- ------------------------------------------------------------
-- UI content
-- ------------------------------------------------------------

-- Fixed positions keep the requested three dashboard columns stable. Progress values
-- are { current, weeklyMax };
-- flat values display only the character's available total.
local DASHBOARD_CURRENCY_DEFS = {
    { childKey = "tidalSparks",          source = "season", storeKey = "sparks",               currencyKey = "tidalSparks",          fallbackName = "Tidal Spark Dust",     valueType = "progress", column = 1, row = 1 },
    { childKey = "nebulousVoidcore",     source = "data",   storeKey = "nebulousVoidcore",     currencyKey = "nebulousVoidcore",     fallbackName = "Nebulous Voidcore",    valueType = "flat",     column = 1, row = 2 },
    { childKey = "restored_coffer_keys", source = "data",   storeKey = "restored_coffer_keys", currencyKey = "restored_coffer_keys", fallbackName = "Restored Coffer Keys", valueType = "flat",     column = 1, row = 3 },
    { childKey = "champion_crests",      source = "season", storeKey = "champion",             currencyKey = "champion_crests",     fallbackName = "Champion Crests",      valueType = "progress", column = 2, row = 1 },
    { childKey = "hero_crests",          source = "season", storeKey = "hero",                 currencyKey = "hero_crests",         fallbackName = "Hero Crests",          valueType = "progress", column = 2, row = 2 },
    { childKey = "myth_crests",          source = "season", storeKey = "myth",                 currencyKey = "myth_crests",         fallbackName = "Myth Crests",          valueType = "progress", column = 2, row = 3 },
    { childKey = "voidlightMarl",        source = "data",   storeKey = "voidlightMarl",        currencyKey = "voidlightMarl",        fallbackName = "Voidlight Marl",       valueType = "flat",     column = 3, row = 1 },
    { childKey = "undercoin",            source = "data",   storeKey = "undercoin",            currencyKey = "undercoin",            fallbackName = "Undercoin",            valueType = "flat",     column = 3, row = 2 },
    { childKey = "coffer_key_shards",    source = "data",   storeKey = "cofferKeyShards",      currencyKey = "cofferKeyShards",      fallbackName = "Coffer Key Shards",    valueType = "progress", column = 3, row = 3 },
}

local STATUS_STYLES = {
    complete = { glyph = "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12:0:0|t", color = constants.colors.success },
    incomplete = { glyph = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:12:12:0:0|t", color = constants.colors.danger },
    inprogress = { glyph = "|TInterface\\GossipFrame\\ActiveQuestIcon:12:12:0:0|t", color = constants.colors.inProgress },
    notstarted = { glyph = "|TInterface\\GossipFrame\\AvailableQuestIcon:12:12:0:0|t", color = constants.colors.warning },
}

local function FindSection(sectionKey)
    for _, section in ipairs(constants.sections) do
        if section.key == sectionKey then
            return section
        end
    end
end

local function SetTextureColor(texture, color)
    texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
end

local function SetFontColor(fontString, color)
    fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
end

local function SetFontSize(fontString, fontObject, size, flags)
    fontString:SetFontObject(fontObject)
    local fontPath, _, inheritedFlags = fontString:GetFont()
    if fontPath then
        fontString:SetFont(fontPath, size, flags or inheritedFlags)
    end
end

local function CreateText(parent, fontObject, size, layer)
    local text = parent:CreateFontString(nil, layer or "OVERLAY")
    SetFontSize(text, fontObject or GameFontNormalSmall, size)
    text:SetJustifyV("MIDDLE")
    return text
end

function AltManager:UpdateFrameScaleControl()
    local frame = self.main_frame
    if not frame or not frame.scaleValue then return end

    local scale = tonumber(constants.config.UI_SCALE) or 1
    frame.scaleValue:SetText(("%d%%"):format(math.floor((scale * 100) + 0.5)))
    local canDecrease = scale > constants.config.UI_SCALE_MIN
    local canIncrease = scale < constants.config.UI_SCALE_MAX
    frame.scaleDecrease:SetEnabled(canDecrease)
    frame.scaleDecrease:SetAlpha(canDecrease and 1 or 0.35)
    frame.scaleIncrease:SetEnabled(canIncrease)
    frame.scaleIncrease:SetAlpha(canIncrease and 1 or 0.35)
end

function AltManager:SetFrameScale(scale)
    scale = tonumber(scale) or constants.config.UI_SCALE
    scale = math.max(constants.config.UI_SCALE_MIN, math.min(constants.config.UI_SCALE_MAX, scale))
    scale = math.floor((scale * 20) + 0.5) / 20

    constants.config.UI_SCALE = scale
    MyAltManagerDB.config.frame_scale = scale
    self.main_frame:SetScale(scale)
    self:UpdateFrameScaleControl()
    C_Timer.After(0, function()
        AltManager:UpdateCofferKeyGlueButton()
    end)
end

function AltManager:AdjustFrameScale(direction)
    local scale = (tonumber(constants.config.UI_SCALE) or 1)
        + ((tonumber(direction) or 0) * constants.config.UI_SCALE_STEP)
    self:SetFrameScale(scale)
end

local function SetGradientTexture(texture, topColor, bottomColor)
    texture:SetGradient(
        "VERTICAL",
        CreateColor(bottomColor[1], bottomColor[2], bottomColor[3], bottomColor[4] or 1),
        CreateColor(topColor[1], topColor[2], topColor[3], topColor[4] or 1)
    )
end

local function CreateInsetBorder(frame)
    if frame.borderParts then return end
    frame.borderParts = {}
    for i = 1, 4 do
        local part = frame:CreateTexture(nil, "OVERLAY")
        SetTextureColor(part, constants.colors.barBorder)
        frame.borderParts[i] = part
    end
    frame.borderParts[1]:SetPoint("TOPLEFT")
    frame.borderParts[1]:SetPoint("TOPRIGHT")
    frame.borderParts[1]:SetHeight(1)
    frame.borderParts[2]:SetPoint("BOTTOMLEFT")
    frame.borderParts[2]:SetPoint("BOTTOMRIGHT")
    frame.borderParts[2]:SetHeight(1)
    frame.borderParts[3]:SetPoint("TOPLEFT")
    frame.borderParts[3]:SetPoint("BOTTOMLEFT")
    frame.borderParts[3]:SetWidth(1)
    frame.borderParts[4]:SetPoint("TOPRIGHT")
    frame.borderParts[4]:SetPoint("BOTTOMRIGHT")
    frame.borderParts[4]:SetWidth(1)
end

local function CreateFlatButton(parent, label)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(18, 18)

    button.background = button:CreateTexture(nil, "BACKGROUND")
    button.background:SetAllPoints()
    SetTextureColor(button.background, constants.colors.barEmpty)

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetColorTexture(
        constants.colors.goldDark[1],
        constants.colors.goldDark[2],
        constants.colors.goldDark[3],
        0.35
    )
    button:SetHighlightTexture(button.highlight)

    button.pushed = button:CreateTexture(nil, "ARTWORK")
    button.pushed:SetAllPoints()
    button.pushed:SetColorTexture(
        constants.colors.gold[1],
        constants.colors.gold[2],
        constants.colors.gold[3],
        0.25
    )
    button:SetPushedTexture(button.pushed)

    button.label = CreateText(button, GameFontNormalSmall, 10)
    button.label:SetAllPoints()
    button.label:SetJustifyH("CENTER")
    button.label:SetText(label)
    SetFontColor(button.label, constants.colors.brightText)
    CreateInsetBorder(button)
    return button
end

function AltManager:InitializeExportCopyBox()
    if self.exportCopyBox then return end

    -- Third-party addons cannot write arbitrary text directly to the operating-system
    -- clipboard. Keep the required EditBox focused and selected but visually hidden so the
    -- player only needs to press Ctrl+C and never has to view or manually select the payload.
    local editBox = CreateFrame("EditBox", "MyAltManagerExportCopyBox", UIParent)
    self.exportCopyBox = editBox
    editBox:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    editBox:SetSize(1, 1)
    editBox:SetAlpha(0)
    editBox:SetAutoFocus(false)
    editBox:SetMaxBytes(0)
    editBox:SetMaxLetters(0)
    editBox:SetScript("OnEscapePressed", function(copyBox)
        copyBox:ClearFocus()
        copyBox:Hide()
        copyBox:SetText("")
        print("MyAltManager: export copy cancelled.")
    end)
    editBox:SetScript("OnKeyDown", function(copyBox, key)
        if key ~= "C" or not IsControlKeyDown() then return end

        -- Let the EditBox process Ctrl+C before clearing the selected export on the next frame.
        C_Timer.After(0, function()
            copyBox:ClearFocus()
            copyBox:Hide()
            copyBox:SetText("")
            print("MyAltManager: data copied to clipboard.")
        end)
    end)
    editBox:Hide()
end

function AltManager:ShowExport()
    self:ValidateReset()
    if self:CanCollectNow() then
        self:CollectAndStore()
    end

    local ok, exportString = pcall(function()
        return self:BuildExportString()
    end)
    if not ok then
        print("MyAltManager: export failed: " .. tostring(exportString))
        return
    end

    self:InitializeExportCopyBox()
    local copyBox = self.exportCopyBox
    copyBox:SetText(exportString)
    copyBox:SetCursorPosition(0)
    copyBox:Show()
    copyBox:SetFocus()
    C_Timer.After(0, function()
        if copyBox:IsShown() then
            copyBox:HighlightText()
        end
    end)
    print("MyAltManager: export ready. Press Ctrl+C to copy it, or Escape to cancel.")
end

function AltManager:InitializeCofferKeyGlueButton()
    if self.cofferKeyGlueButton or InCombatLockdown() then return end

    local glue = constants.COFFER_KEY_GLUE
    local button = CreateFrame(
        "Button",
        "MyAltManagerCofferKeyGlueButton",
        UIParent,
        "SecureActionButtonTemplate"
    )
    self.cofferKeyGlueButton = button
    button:SetFrameStrata("FULLSCREEN_DIALOG")
    button:SetFrameLevel((self.main_frame and self.main_frame:GetFrameLevel() or 0) + 100)
    button:SetHitRectInsets(0, 0, 0, 0)
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("useOnKeyDown", false)
    button:SetAttribute("type1", "item")
    button:SetAttribute("item", "item:" .. glue.ITEM_ID)

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetAllPoints()
    button.highlight:SetColorTexture(
        constants.colors.gold[1],
        constants.colors.gold[2],
        constants.colors.gold[3],
        0.18
    )
    button:SetHighlightTexture(button.highlight)

    button:SetScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip:SetText("Coffer Key Glue")
        GameTooltip:AddLine(("Click to convert all %s available Coffer Key Shards into Restored Coffer Keys."):format(
            FormatWholeNumber(AltManager._cofferKeyGlueShardCount)
        ), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    button:SetScript("OnHide", GameTooltip_Hide)
    button:Hide()
end

function AltManager:PositionCofferKeyGlueButton(target)
    local button = self.cofferKeyGlueButton
    if not button or not target then return false end

    local leftFrame = target.iconButton or target
    local rightFrame = target.bar or target
    local left = leftFrame:GetLeft()
    local right = rightFrame:GetRight()
    local leftBottom = leftFrame:GetBottom()
    local rightBottom = rightFrame:GetBottom()
    local leftTop = leftFrame:GetTop()
    local rightTop = rightFrame:GetTop()
    if not left or not right or not leftBottom or not rightBottom or not leftTop or not rightTop then
        return false
    end

    local bottom = math.min(leftBottom, rightBottom)
    local width = right - left
    local height = math.max(leftTop, rightTop) - bottom
    if width <= 0 or height <= 0 then return false end

    local uiScale = UIParent:GetEffectiveScale()
    local targetScale = target:GetEffectiveScale()
    if not uiScale or uiScale <= 0 or not targetScale or targetScale <= 0 then return false end

    local scaleRatio = targetScale / uiScale
    button:ClearAllPoints()
    button:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left * scaleRatio, bottom * scaleRatio)
    button:SetSize(width * scaleRatio, height * scaleRatio)
    return true
end

function AltManager:HideCofferKeyGlueButton()
    local button = self.cofferKeyGlueButton
    if not button then return end

    if InCombatLockdown() then
        self._cofferKeyGlueUpdatePending = true
        return
    end

    if button._visibilityDriven then
        UnregisterStateDriver(button, "visibility")
        button._visibilityDriven = false
    end
    button:Hide()
    button:ClearAllPoints()
end

function AltManager:UpdateCofferKeyGlueButton()
    if InCombatLockdown() then
        self._cofferKeyGlueUpdatePending = true
        return
    end

    self._cofferKeyGlueUpdatePending = false
    self:InitializeCofferKeyGlueButton()
    local button = self.cofferKeyGlueButton
    if not button then return end

    local target = self._cofferKeyGlueTarget
    local shouldShow = target ~= nil and self.main_frame and self.main_frame:IsShown()
    if not shouldShow or not self:PositionCofferKeyGlueButton(target) then
        self:HideCofferKeyGlueButton()
        return
    end

    if not button._visibilityDriven then
        RegisterStateDriver(button, "visibility", "[combat] hide; show")
        button._visibilityDriven = true
    end
    button:Show()
end

function AltManager:DetachCofferKeyGlueCastBar()
    local bar = self._cofferKeyGlueCastBar
    if not bar then return end

    if bar.castProgress then
        bar.castProgress:SetScript("OnUpdate", nil)
        bar.castProgress:Hide()
    end
    self._cofferKeyGlueCastBar = nil
end

function AltManager:StopCofferKeyGlueCastDisplay()
    local bar = self._cofferKeyGlueCastBar
    local target = self._cofferKeyGlueTarget
    self._cofferKeyGlueCast = nil
    self:DetachCofferKeyGlueCastBar()

    if bar and target and target.bar == bar then
        bar.text:SetText("Convert Keys")
    end
end

function AltManager:RenderCofferKeyGlueCastDisplay()
    local cast = self._cofferKeyGlueCast
    local target = self._cofferKeyGlueTarget
    if not cast or not target or not target.bar or not target.bar.castProgress then return end

    local now = GetTime()
    if now >= cast.endTime then
        self:StopCofferKeyGlueCastDisplay()
        return
    end

    self:DetachCofferKeyGlueCastBar()
    local bar = target.bar
    local progress = bar.castProgress
    local duration = math.max(0.001, cast.endTime - cast.startTime)
    self._cofferKeyGlueCastBar = bar

    bar.text:SetText("Converting")
    progress:SetMinMaxValues(0, duration)
    progress:SetValue(math.max(0, math.min(duration, now - cast.startTime)))
    progress:SetScript("OnUpdate", function(castBar)
        local activeCast = AltManager._cofferKeyGlueCast
        if not activeCast or AltManager._cofferKeyGlueCastBar ~= castBar:GetParent() then
            castBar:SetScript("OnUpdate", nil)
            castBar:Hide()
            return
        end

        local currentTime = GetTime()
        local activeDuration = math.max(0.001, activeCast.endTime - activeCast.startTime)
        castBar:SetMinMaxValues(0, activeDuration)
        castBar:SetValue(math.max(0, math.min(activeDuration, currentTime - activeCast.startTime)))
        if currentTime >= activeCast.endTime then
            AltManager:StopCofferKeyGlueCastDisplay()
        end
    end)
    progress:Show()
end

function AltManager:OnCofferKeyGlueSpellcastStart(unit, eventSpellID)
    if unit ~= "player" then return end

    local _, _, _, startTimeMS, endTimeMS, _, _, _, castingSpellID = UnitCastingInfo("player")
    local spellID = tonumber(castingSpellID) or tonumber(eventSpellID)
    if spellID ~= constants.COFFER_KEY_GLUE.SPELL_ID then return end

    startTimeMS = tonumber(startTimeMS)
    endTimeMS = tonumber(endTimeMS)
    if not startTimeMS or not endTimeMS or endTimeMS <= startTimeMS then return end

    self._cofferKeyGlueCast = {
        startTime = startTimeMS / 1000,
        endTime = endTimeMS / 1000,
    }
    self:RenderCofferKeyGlueCastDisplay()
end

function AltManager:OnCofferKeyGlueSpellcastEnded(unit, eventSpellID)
    if unit ~= "player" or not self._cofferKeyGlueCast then return end

    local spellID = tonumber(eventSpellID)
    if spellID and spellID ~= constants.COFFER_KEY_GLUE.SPELL_ID then return end
    self:StopCofferKeyGlueCastDisplay()
end

function AltManager:GetColumnLayout()
    local layout = constants.layout
    local columns = {
        character = { key = "character", x = 0, width = layout.COL_CHARACTER, visible = true },
        mplus = { key = "mplus", width = layout.COL_MPLUS, visible = self:IsRowVisible("mythic_plus") },
        vault = { key = "vault", width = layout.COL_VAULT, visible = self:IsRowVisible("great_vault") },
        currency = { key = "currency", width = layout.COL_CURRENCY, visible = self:IsRowVisible("currencies") },
    }

    local ordered = { columns.character }
    for _, key in ipairs({ "mplus", "vault", "currency" }) do
        if columns[key].visible then
            ordered[#ordered + 1] = columns[key]
        end
    end

    local innerWidth = layout.FRAME_WIDTH - (2 * layout.PAD_X)
    local used = layout.COL_GAP * math.max(0, #ordered - 1)
    for _, column in ipairs(ordered) do
        used = used + column.width
    end

    local extra = math.max(0, innerWidth - used)
    local recipient = columns.vault.visible and columns.vault
        or (columns.currency.visible and columns.currency)
        or (columns.mplus.visible and columns.mplus)
        or columns.character
    recipient.width = recipient.width + extra

    local x = 0
    for index, column in ipairs(ordered) do
        column.x = x
        x = x + column.width
        if index < #ordered then
            x = x + layout.COL_GAP
        end
    end

    columns.ordered = ordered
    return columns
end

local function ResetRowPool(_, row)
    row:Hide()
    row:ClearAllPoints()
    row:SetScript("OnClick", nil)
    row:SetScript("OnEnter", nil)
    row:SetScript("OnLeave", nil)
    row.guid = nil
    row.rowData = nil
    if row.highlight then row.highlight:Hide() end
end

local function ResetDrawerPool(_, drawer)
    drawer:Hide()
    drawer:ClearAllPoints()
    if drawer.texts then
        for _, text in ipairs(drawer.texts) do
            text:Hide()
        end
    end
end

function AltManager:InitializeFrame()
    local frame = self.main_frame
    if frame.uiInitialized then return end
    frame.uiInitialized = true

    local layout = constants.layout
    frame:SetScale(constants.config.UI_SCALE)
    frame:SetSize(layout.FRAME_WIDTH, layout.TITLE_HEIGHT + layout.HEADER_HEIGHT + layout.FOOTER_HEIGHT + 1)

    -- The solid base guarantees an opaque window even if gradient rendering is unavailable.
    frame.backgroundBase = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    frame.backgroundBase:SetAllPoints()
    frame.backgroundBase:SetColorTexture(0x17 / 255, 0x13 / 255, 0x1E / 255, 1)
    frame.background = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    frame.background:SetAllPoints()
    SetGradientTexture(frame.background, constants.colors.frameTop, constants.colors.frameBottom)

    frame.titleBar = CreateFrame("Frame", nil, frame)
    frame.titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    frame.titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    frame.titleBar:SetHeight(layout.TITLE_HEIGHT - 1)
    frame.titleBar.background = frame.titleBar:CreateTexture(nil, "ARTWORK")
    frame.titleBar.background:SetAllPoints()
    SetGradientTexture(frame.titleBar.background, constants.colors.titleTop, constants.colors.titleBottom)

    frame.title = CreateText(frame.titleBar, GameFontNormal, 15)
    frame.title:SetPoint("CENTER")
    frame.title:SetText("MyAltManager")
    SetFontColor(frame.title, constants.colors.titleText)

    frame.scaleControl = CreateFrame("Frame", nil, frame.titleBar)
    frame.scaleControl:SetPoint("LEFT", frame.titleBar, "LEFT", 8, 0)
    frame.scaleControl:SetSize(112, layout.TITLE_HEIGHT - 3)

    frame.scaleLabel = CreateText(frame.scaleControl, GameFontNormalSmall, 10)
    frame.scaleLabel:SetPoint("LEFT", frame.scaleControl, "LEFT", 0, 0)
    frame.scaleLabel:SetSize(34, 20)
    frame.scaleLabel:SetJustifyH("LEFT")
    frame.scaleLabel:SetText("Scale:")
    SetFontColor(frame.scaleLabel, constants.colors.brightText)

    frame.scaleDecrease = CreateFlatButton(frame.scaleControl, "-")
    frame.scaleDecrease:SetPoint("LEFT", frame.scaleLabel, "RIGHT", 2, 0)
    frame.scaleDecrease:SetScript("OnClick", function() AltManager:AdjustFrameScale(-1) end)

    frame.scaleValue = CreateText(frame.scaleControl, GameFontNormalSmall, 10)
    frame.scaleValue:SetPoint("LEFT", frame.scaleDecrease, "RIGHT", 1, 0)
    frame.scaleValue:SetSize(36, 18)
    frame.scaleValue:SetJustifyH("CENTER")
    SetFontColor(frame.scaleValue, constants.colors.brightText)

    frame.scaleIncrease = CreateFlatButton(frame.scaleControl, "+")
    frame.scaleIncrease:SetPoint("LEFT", frame.scaleValue, "RIGHT", 1, 0)
    frame.scaleIncrease:SetScript("OnClick", function() AltManager:AdjustFrameScale(1) end)
    self:UpdateFrameScaleControl()

    frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    frame.closeButton:SetScale(0.90)
    frame.closeButton:SetScript("OnClick", function() AltManager:HideInterface() end)

    frame.exportButton = CreateFlatButton(frame, "Export")
    frame.exportButton:SetPoint("RIGHT", frame.closeButton, "LEFT", -4, 0)
    frame.exportButton:SetSize(54, 18)
    frame.exportButton:SetScript("OnClick", function() AltManager:ShowExport() end)
    frame:SetScript("OnShow", function()
        AltManager:UpdateCofferKeyGlueButton()
    end)
    frame:SetScript("OnHide", function()
        AltManager:StopCofferKeyGlueCastDisplay()
        AltManager._cofferKeyGlueTarget = nil
        AltManager:HideCofferKeyGlueButton()
    end)

    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame.titleBar:EnableMouse(true)
    frame.titleBar:RegisterForDrag("LeftButton")
    frame.titleBar:SetScript("OnDragStart", function()
        frame:StartMoving()
    end)
    frame.titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = frame:GetPoint(1)
        MyAltManagerDB.config.framePoint = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
        AltManager:UpdateCofferKeyGlueButton()
    end)

    local savedPoint = MyAltManagerDB.config.framePoint
    if type(savedPoint) == "table" and savedPoint.point then
        frame:ClearAllPoints()
        frame:SetPoint(
            savedPoint.point,
            UIParent,
            savedPoint.relativePoint or savedPoint.point,
            tonumber(savedPoint.x) or 0,
            tonumber(savedPoint.y) or 0
        )
    end

    frame.headerFrame = CreateFrame("Frame", nil, frame)
    frame.headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -layout.TITLE_HEIGHT)
    frame.headerFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -layout.TITLE_HEIGHT)
    frame.headerFrame:SetHeight(layout.HEADER_HEIGHT)
    frame.headers = {}
    for key, label in pairs({
        character = "CHARACTER",
        mplus = "MYTHIC+",
        vault = "GREAT VAULT",
        currency = "CURRENCIES",
    }) do
        local header = CreateText(frame.headerFrame, GameFontNormalSmall, 10.5)
        header:SetText(label)
        header:SetJustifyH(key == "character" and "LEFT" or "CENTER")
        SetFontColor(header, constants.colors.brightText)
        frame.headers[key] = header
    end
    frame.headerSeparator = frame.headerFrame:CreateTexture(nil, "ARTWORK")
    frame.headerSeparator:SetPoint("BOTTOMLEFT", frame.headerFrame, "BOTTOMLEFT", layout.PAD_X, 0)
    frame.headerSeparator:SetPoint("BOTTOMRIGHT", frame.headerFrame, "BOTTOMRIGHT", -layout.PAD_X, 0)
    frame.headerSeparator:SetHeight(1)
    SetTextureColor(frame.headerSeparator, constants.colors.barBorder)

    frame.scrollFrame = CreateFrame("ScrollFrame", "AltManagerScrollFrame", frame, "UIPanelScrollFrameTemplate")
    local scrollBar = frame.scrollFrame.ScrollBar or _G.AltManagerScrollFrameScrollBar
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPLEFT", frame.scrollFrame, "TOPRIGHT", 1, -16)
        scrollBar:SetPoint("BOTTOMLEFT", frame.scrollFrame, "BOTTOMRIGHT", 1, 16)
        scrollBar:SetWidth(12)
        scrollBar:Hide()
    end
    frame.scrollChild = CreateFrame("Frame", nil, frame.scrollFrame)
    frame.scrollChild:SetSize(layout.FRAME_WIDTH - (2 * layout.PAD_X), 1)
    frame.scrollFrame:SetScrollChild(frame.scrollChild)

    frame.footer = CreateFrame("Frame", nil, frame)
    frame.footerCurseSurge = CreateFrame("Button", nil, frame.footer)
    frame.footerCurseSurge:SetPoint("BOTTOMLEFT", frame.footer, "BOTTOMLEFT", layout.PAD_X, 0)
    frame.footerCurseSurge:SetSize(300, layout.FOOTER_HEIGHT)
    frame.footerCurseSurge:RegisterForClicks("LeftButtonUp")
    frame.footerCurseSurge:SetScript("OnClick", function()
        AltManager:ToggleCurseSurgeTracker()
    end)
    -- Anchored on one edge only so the font string self-sizes; UpdateFooterCurseSurge then
    -- shrinks the button onto its text, keeping the location button beside it clickable.
    frame.footerCurseSurge.text = CreateText(frame.footerCurseSurge, GameFontNormalSmall, 9)
    frame.footerCurseSurge.text:SetPoint("LEFT", frame.footerCurseSurge, "LEFT", 0, 0)
    frame.footerCurseSurge.text:SetJustifyH("LEFT")
    SetFontColor(frame.footerCurseSurge.text, constants.colors.brightText)

    -- Separate button so clicking the coordinates tracks the surge without toggling the tracker.
    frame.footerCurseSurgeLocation = CreateFrame("Button", nil, frame.footer)
    frame.footerCurseSurgeLocation:SetPoint("BOTTOMLEFT", frame.footerCurseSurge, "BOTTOMRIGHT", 0, 0)
    frame.footerCurseSurgeLocation:SetSize(1, layout.FOOTER_HEIGHT)
    frame.footerCurseSurgeLocation:RegisterForClicks("LeftButtonUp")
    frame.footerCurseSurgeLocation:SetScript("OnClick", function(button)
        AltManager:TrackCurseSurgeLocation()
        -- Re-run OnEnter so the tooltip flips between track and untrack under the cursor.
        local onEnter = button:GetScript("OnEnter")
        if onEnter then onEnter(button) end
    end)
    -- The coordinates carry their own colour code, so highlighting re-renders rather than
    -- recolouring the font string, which an embedded escape sequence would override.
    frame.footerCurseSurgeLocation:SetScript("OnEnter", function(button)
        button.isHighlighted = true
        AltManager:RenderFooterCurseSurgeLocation()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(AltManager:GetActiveCurseSurgeEventName() or "Curse Surge")
        GameTooltip:AddLine(AltManager:IsTrackingCurseSurgeLocation()
            and "Click to remove focus tracking."
            or "Click to track this location.", 1, 1, 1)
        GameTooltip:Show()
    end)
    frame.footerCurseSurgeLocation:SetScript("OnLeave", function(button)
        button.isHighlighted = false
        AltManager:RenderFooterCurseSurgeLocation()
        GameTooltip:Hide()
    end)
    frame.footerCurseSurgeLocation.text = CreateText(frame.footerCurseSurgeLocation, GameFontNormalSmall, 9)
    frame.footerCurseSurgeLocation.text:SetPoint("LEFT", frame.footerCurseSurgeLocation, "LEFT", 0, 0)
    frame.footerCurseSurgeLocation.text:SetJustifyH("LEFT")
    SetFontColor(frame.footerCurseSurgeLocation.text, constants.colors.brightText)
    frame.footerCurseSurgeLocation:Hide()

    frame.footerVersion = CreateText(frame.footer, GameFontNormalSmall, 9)
    frame.footerVersion:SetPoint("BOTTOM", frame.footer, "BOTTOM", 0, 0)
    frame.footerVersion:SetSize(180, layout.FOOTER_HEIGHT)
    frame.footerVersion:SetJustifyH("CENTER")
    frame.footerVersion:SetText(constants.VERSION)
    SetFontColor(frame.footerVersion, constants.colors.brightText)

    frame.footerReset = CreateText(frame.footer, GameFontNormalSmall, 9)
    frame.footerReset:SetPoint("BOTTOMRIGHT", frame.footer, "BOTTOMRIGHT", -layout.PAD_X, 0)
    frame.footerReset:SetSize(300, layout.FOOTER_HEIGHT)
    frame.footerReset:SetJustifyH("RIGHT")
    SetFontColor(frame.footerReset, constants.colors.brightText)

    frame.footer.separator = frame.footer:CreateTexture(nil, "ARTWORK")
    frame.footer.separator:SetPoint("TOPLEFT", frame.footer, "TOPLEFT", layout.PAD_X, 0)
    frame.footer.separator:SetPoint("TOPRIGHT", frame.footer, "TOPRIGHT", -layout.PAD_X, 0)
    frame.footer.separator:SetHeight(1)
    SetTextureColor(frame.footer.separator, constants.colors.drawerDivider)

    frame:HookScript("OnHide", function() AltManager:StopFooterTicker() end)

    self.rowPool = CreateFramePool("Button", frame.scrollChild, nil, ResetRowPool)
    self.drawerPool = CreateFramePool("Frame", frame.scrollChild, nil, ResetDrawerPool)
    self:MakeBorder(frame, 1)
    self:InitializeCurseSurgeTracker()
end

function AltManager:UpdateColumnHeaders(columnLayout)
    local layout = constants.layout
    for key, header in pairs(self.main_frame.headers) do
        local column = columnLayout[key]
        if column and column.visible then
            header:ClearAllPoints()
            header:SetPoint("TOPLEFT", self.main_frame.headerFrame, "TOPLEFT", layout.PAD_X + column.x, 0)
            header:SetSize(column.width, layout.HEADER_HEIGHT - 1)
            header:Show()
        else
            header:Hide()
        end
    end
end

local function GetClassColor(class)
    return RAID_CLASS_COLORS[class] or HIGHLIGHT_FONT_COLOR or { r = 1, g = 1, b = 1 }
end

local function GetKeystoneColor(level)
    level = tonumber(level) or 0
    if level >= 10 then
        return 1, 0.5, 0
    elseif level >= 7 then
        return 0.64, 0.21, 0.93
    elseif level >= 5 then
        return 0, 0.44, 0.87
    end
    return 0.12, 1, 0
end

local function ToggleFromChild(child)
    local row = child.ownerRow
    if row and row.guid then
        GameTooltip:Hide()
        AltManager:ToggleRowDrawer(row.guid)
    end
end

local function ShowVaultTooltip(segment)
    if not segment.earned then return end
    local link = segment.activityID and C_WeeklyRewards.GetExampleRewardItemHyperlinks(segment.activityID)
    GameTooltip:SetOwner(segment, "ANCHOR_RIGHT")
    if link then
        GameTooltip:SetHyperlink(link)
    else
        GameTooltip:SetText(("Great Vault reward — item level %s"):format(FormatWholeNumber(segment.ilvl or "?")))
    end
    GameTooltip:Show()
end

local function ShowCurrencyTooltip(button)
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetText(button.currencyName or "Currency")
    GameTooltip:Show()
end

function AltManager:InitializeRow(row)
    if row.initialized then return end
    row.initialized = true
    local layout = constants.layout

    row:RegisterForClicks("LeftButtonUp")
    row.separator = row:CreateTexture(nil, "ARTWORK")
    row.separator:SetPoint("TOPLEFT")
    row.separator:SetPoint("TOPRIGHT")
    row.separator:SetHeight(1)
    SetTextureColor(row.separator, constants.colors.rowSeparator)

    row.stripe = row:CreateTexture(nil, "ARTWORK")
    row.stripe:SetSize(layout.STRIPE_W, layout.STRIPE_H)

    row.nameText = CreateText(row, GameFontNormal, 12)
    row.nameText:SetJustifyH("LEFT")
    row.realmText = CreateText(row, GameFontNormalSmall, 9.5)
    row.realmText:SetJustifyH("LEFT")
    row.detailText = CreateText(row, GameFontNormalSmall, 9)
    row.detailText:SetJustifyH("LEFT")
    row.removeButton = self:CreateRemoveButton(row)

    row.tierHit = CreateFrame("Button", nil, row)
    row.tierHit.ownerRow = row
    row.tierHit:RegisterForClicks("LeftButtonUp")

    row.catalystHit = CreateFrame("Button", nil, row)
    row.catalystHit.ownerRow = row
    row.catalystHit:RegisterForClicks("LeftButtonUp")

    row.mplusFrame = CreateFrame("Frame", nil, row)
    row.mplusFrame.score = CreateText(row.mplusFrame, GameFontNormal, 15)
    row.mplusFrame.score:SetJustifyH("CENTER")
    row.mplusFrame.key = CreateText(row.mplusFrame, GameFontNormalSmall, 9.5)
    row.mplusFrame.key:SetJustifyH("CENTER")
    row.mplusFrame.weekly = CreateText(row.mplusFrame, GameFontNormalSmall, 9.5)
    row.mplusFrame.weekly:SetJustifyH("CENTER")

    row.vaultFrame = CreateFrame("Frame", nil, row)
    row.vaultFrame.tracks = {}
    local trackNames = { "RAIDS", "DUNGEONS", "OUTDOORS" }
    for trackIndex, trackName in ipairs(trackNames) do
        local track = {}
        track.label = CreateText(row.vaultFrame, GameFontNormalSmall, 8.5)
        track.label:SetText(trackName)
        track.label:SetJustifyH("RIGHT")
        SetFontColor(track.label, constants.colors.header)
        track.segments = {}
        for slotIndex = 1, 3 do
            local segment = CreateFrame("Button", nil, row.vaultFrame)
            segment.ownerRow = row
            segment:RegisterForClicks("LeftButtonUp")
            segment.background = segment:CreateTexture(nil, "BACKGROUND")
            segment.background:SetAllPoints()
            segment.fill = segment:CreateTexture(nil, "ARTWORK")
            segment.fill:SetAllPoints()
            segment.text = CreateText(segment, GameFontNormalSmall, 8.5)
            segment.text:SetPoint("CENTER")
            segment.text:SetJustifyH("CENTER")
            segment:SetScript("OnEnter", ShowVaultTooltip)
            segment:SetScript("OnLeave", GameTooltip_Hide)
            CreateInsetBorder(segment)
            track.segments[slotIndex] = segment
        end
        row.vaultFrame.tracks[trackIndex] = track
    end

    row.currencyFrame = CreateFrame("Frame", nil, row)
    row.currencyFrame.cells = {}
    for index = 1, #DASHBOARD_CURRENCY_DEFS do
        local cell = CreateFrame("Frame", nil, row.currencyFrame)
        cell.iconButton = CreateFrame("Button", nil, cell)
        cell.iconButton.ownerRow = row
        cell.iconButton:RegisterForClicks("LeftButtonUp")
        cell.iconButton.texture = cell.iconButton:CreateTexture(nil, "ARTWORK")
        cell.iconButton.texture:SetAllPoints()
        cell.iconButton.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        cell.iconButton:SetScript("OnEnter", ShowCurrencyTooltip)
        cell.iconButton:SetScript("OnLeave", GameTooltip_Hide)

        cell.bar = CreateFrame("StatusBar", nil, cell)
        cell.bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        cell.bar.background = cell.bar:CreateTexture(nil, "BACKGROUND")
        cell.bar.background:SetAllPoints()
        SetTextureColor(cell.bar.background, constants.colors.barEmpty)
        cell.bar.text = CreateText(cell.bar, GameFontNormalSmall, 8.5)
        cell.bar.text:SetPoint("CENTER")
        cell.bar.text:SetJustifyH("CENTER")
        SetFontColor(cell.bar.text, constants.colors.currencyText)
        cell.bar.castProgress = CreateFrame("StatusBar", nil, cell.bar)
        cell.bar.castProgress:SetPoint("TOPLEFT", cell.bar, "BOTTOMLEFT", 1, -1)
        cell.bar.castProgress:SetPoint("TOPRIGHT", cell.bar, "BOTTOMRIGHT", -1, -1)
        cell.bar.castProgress:SetHeight(3)
        cell.bar.castProgress:SetFrameLevel(cell.bar:GetFrameLevel() + 1)
        cell.bar.castProgress:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
        SetTextureColor(cell.bar.castProgress:GetStatusBarTexture(), constants.colors.currencyFill)
        cell.bar.castProgress.background = cell.bar.castProgress:CreateTexture(nil, "BACKGROUND")
        cell.bar.castProgress.background:SetAllPoints()
        SetTextureColor(cell.bar.castProgress.background, constants.colors.barEmpty)
        cell.bar.castProgress:Hide()
        CreateInsetBorder(cell.bar)
        row.currencyFrame.cells[index] = cell
    end

    row.interactiveChildren = { row.tierHit, row.catalystHit }
    for _, track in ipairs(row.vaultFrame.tracks) do
        for _, segment in ipairs(track.segments) do
            row.interactiveChildren[#row.interactiveChildren + 1] = segment
        end
    end
    for _, cell in ipairs(row.currencyFrame.cells) do
        row.interactiveChildren[#row.interactiveChildren + 1] = cell.iconButton
    end
end

function AltManager:ConfigureRowInteractions(row)
    if not row.highlight then
        row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
        row.highlight:SetAllPoints()
        row.highlight:SetColorTexture(1, 1, 1, 0.03)
        row.highlight:Hide()
    end
    row:SetScript("OnClick", function(button) AltManager:ToggleRowDrawer(button.guid) end)
    row:SetScript("OnEnter", function(button) button.highlight:Show() end)
    row:SetScript("OnLeave", function(button) button.highlight:Hide() end)
    for _, child in ipairs(row.interactiveChildren) do
        child:SetScript("OnClick", ToggleFromChild)
    end
end

function AltManager:ConfigureCharacterCell(row, data, column)
    local classColor = GetClassColor(data.class)
    row.stripe:ClearAllPoints()
    row.stripe:SetPoint("LEFT", row, "LEFT", column.x, 0)
    row.stripe:SetColorTexture(classColor.r or 1, classColor.g or 1, classColor.b or 1, 1)

    local textX = column.x + constants.layout.STRIPE_W + 7
    local textWidth = math.max(1, column.width - constants.layout.STRIPE_W - 10)
    row.nameText:ClearAllPoints()
    row.nameText:SetPoint("TOPLEFT", row, "TOPLEFT", textX, -5)
    row.nameText:SetSize(textWidth - remove_button_size - 3, 15)
    row.nameText:SetText(data.name or "Unknown")
    row.nameText:SetTextColor(classColor.r or 1, classColor.g or 1, classColor.b or 1, 1)

    local nameWidth = math.min(row.nameText:GetStringWidth() + 4, textWidth - remove_button_size)
    row.removeButton:ClearAllPoints()
    row.removeButton:SetPoint("TOPLEFT", row, "TOPLEFT", textX + nameWidth, -4)
    row.removeButton:SetSize(remove_button_size, remove_button_size)
    row.removeButton.guid = data.guid
    row.removeButton:Show()

    row.realmText:ClearAllPoints()
    row.realmText:SetPoint("TOPLEFT", row, "TOPLEFT", textX, -21)
    row.realmText:SetSize(textWidth, 13)
    row.realmText:SetText(("|cff90899a%s · |r|cffd8b85a%s ilvl|r"):format(
        tostring(data.realmName or "Unknown realm"),
        FormatWholeNumber(data.ilevel)
    ))

    local isCurrentSeason = tonumber(data.seasonID) == constants.SEASON_ID
    local tierPieces = isCurrentSeason and math.max(0, math.min(5, tonumber(data.tierPieces) or 0)) or 0
    local catalyst = isCurrentSeason and (data.catalyst or {}) or {}
    local catalystCurrent = tonumber(catalyst.current) or 0
    local catalystMax = tonumber(catalyst.max) or 0
    row.detailText:ClearAllPoints()
    row.detailText:SetPoint("TOPLEFT", row, "TOPLEFT", textX, -37)
    row.detailText:SetSize(textWidth, 13)
    row.detailText:SetText(("|cff90899aTier Set: |r|cffc5c0cd%d/5|r |cff90899a· Catalyst Charges: |r|cffc5c0cd%d/%d|r"):format(
        tierPieces,
        catalystCurrent,
        catalystMax
    ))

    row.tierHit:ClearAllPoints()
    row.tierHit:SetPoint("TOPLEFT", row, "TOPLEFT", textX, -35)
    row.tierHit:SetSize(math.min(82, textWidth * 0.4), 15)
    row.catalystHit:ClearAllPoints()
    row.catalystHit:SetPoint("TOPRIGHT", row, "TOPLEFT", column.x + column.width, -35)
    row.catalystHit:SetSize(math.max(1, textWidth - 84), 15)
end

function AltManager:ConfigureMythicCell(row, data, column)
    local frame = row.mplusFrame
    if not column.visible then
        frame:Hide()
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", row, "TOPLEFT", column.x, 0)
    frame:SetSize(column.width, constants.layout.ROW_HEIGHT)
    frame.score:ClearAllPoints()
    frame.score:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -3)
    frame.score:SetSize(column.width, 18)
    frame.key:ClearAllPoints()
    frame.key:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -21)
    frame.key:SetSize(column.width, 15)
    frame.weekly:ClearAllPoints()
    frame.weekly:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -37)
    frame.weekly:SetSize(column.width, 15)

    local mplus = tonumber(data.seasonID) == constants.SEASON_ID and (data.mplus or {}) or {}
    frame.score:SetText(FormatWholeNumber(mplus.score))
    frame.score:SetTextColor(tonumber(mplus.r) or 1, tonumber(mplus.g) or 1, tonumber(mplus.b) or 1, 1)

    local mapID = tonumber(mplus.keyMapID)
    local level = tonumber(mplus.keyLevel)
    if mapID and level and level > 0 then
        frame.key:SetText(("+%d %s"):format(level, GetDungeonShortName(mapID)))
        frame.key:SetTextColor(GetKeystoneColor(level))
    else
        frame.key:SetText("No Keystone")
        SetFontColor(frame.key, constants.colors.muted)
    end

    local weeklyHighest = GetWeeklyHighestKeystone(data.runHistory)
    if weeklyHighest then
        local weeklyMap = weeklyHighest.mapID and (" " .. GetDungeonShortName(weeklyHighest.mapID)) or ""
        frame.weekly:SetText(("+%d%s"):format(weeklyHighest.level, weeklyMap))
        frame.weekly:SetTextColor(GetKeystoneColor(weeklyHighest.level))
    else
        frame.weekly:SetText("No Weekly Highest")
        SetFontColor(frame.weekly, constants.colors.muted)
    end
    frame:Show()
end

function AltManager:ConfigureVaultCell(row, data, column)
    local frame = row.vaultFrame
    if not column.visible then
        frame:Hide()
        return
    end

    local layout = constants.layout
    local trackDefinitions = {
        { key = "raid", thresholds = { 2, 4, 6 } },
        { key = "dungeon", thresholds = { 1, 4, 8 } },
        { key = "world", thresholds = { 2, 4, 8 } },
    }
    local segmentWidth = math.max(1, (column.width - layout.VAULT_LABEL_W - 7) / 3)
    local totalHeight = (3 * layout.BAR_H) + (2 * layout.BAR_GAP)
    local topOffset = (layout.ROW_HEIGHT - totalHeight) / 2
    local vault = data.vault or {}
    local currentCharacter = data.guid == UnitGUID("player")

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", row, "TOPLEFT", column.x, 0)
    frame:SetSize(column.width, layout.ROW_HEIGHT)

    for trackIndex, definition in ipairs(trackDefinitions) do
        local trackWidget = frame.tracks[trackIndex]
        local trackData = vault[definition.key] or {}
        local y = -(topOffset + ((trackIndex - 1) * (layout.BAR_H + layout.BAR_GAP)))
        trackWidget.label:ClearAllPoints()
        trackWidget.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, y)
        trackWidget.label:SetSize(layout.VAULT_LABEL_W, layout.BAR_H)

        for slotIndex, segment in ipairs(trackWidget.segments) do
            local slot = trackData[slotIndex] or {}
            local progress = tonumber(slot.progress) or 0
            local threshold = tonumber(slot.threshold) or definition.thresholds[slotIndex]
            if threshold <= 0 then threshold = definition.thresholds[slotIndex] end
            local earned = slot.earned == true or progress >= threshold

            segment:ClearAllPoints()
            segment:SetPoint(
                "TOPLEFT",
                frame,
                "TOPLEFT",
                layout.VAULT_LABEL_W + 7 + ((slotIndex - 1) * segmentWidth),
                y
            )
            segment:SetSize(segmentWidth, layout.BAR_H)
            segment.earned = earned
            segment.activityID = currentCharacter and slot.activityID or nil
            segment.ilvl = slot.ilvl or slot.raidString or "?"

            if earned then
                SetTextureColor(segment.background, constants.colors.vaultComplete)
                segment.fill:Hide()
                segment.text:SetText(FormatWholeNumber(slot.ilvl or slot.raidString or "?"))
                SetFontColor(segment.text, constants.colors.vaultText)
            else
                SetTextureColor(segment.background, progress > 0 and constants.colors.vaultProgress or constants.colors.vaultNotStarted)
                segment.fill:Hide()
                segment.text:SetText(("%d/%d"):format(progress, threshold))
                SetFontColor(segment.text, constants.colors.vaultText)
            end
            segment:Show()
        end
    end
    frame:Show()
end

function AltManager:ConfigureCurrencyCell(row, data, column)
    local frame = row.currencyFrame
    if not column.visible then
        frame:Hide()
        return
    end

    local layout = constants.layout
    for _, cell in ipairs(frame.cells) do
        cell:Hide()
    end

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", row, "TOPLEFT", column.x, 0)
    frame:SetSize(column.width, layout.ROW_HEIGHT)
    local columnCount = 3
    local rowCount = 3
    local cellGap = 5
    local cellWidth = math.max(1, (column.width - ((columnCount - 1) * cellGap)) / columnCount)
    local totalHeight = (rowCount * layout.BAR_H) + ((rowCount - 1) * layout.BAR_GAP)
    local topOffset = (layout.ROW_HEIGHT - totalHeight) / 2

    for definitionIndex, definition in ipairs(DASHBOARD_CURRENCY_DEFS) do
        if self:IsRowVisible(definition.childKey) then
            local cell = frame.cells[definitionIndex]
            local columnIndex = definition.column - 1
            local rowIndex = definition.row - 1
            local currencyID = constants.currencies[definition.currencyKey]
            local info = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID) or nil
            local values
            if definition.source == "season" then
                values = tonumber(data.seasonID) == constants.SEASON_ID
                    and data.season and data.season[definition.storeKey] or nil
            else
                values = data[definition.storeKey]
            end

            local isCofferKeyShards = definition.childKey == "coffer_key_shards"
            local current
            local maximum
            local available
            if isCofferKeyShards and type(values) == "table" and values.available ~= nil then
                available = tonumber(values.available) or 0
                current = tonumber(values.earnedThisWeek) or available
                maximum = tonumber(values.weeklyMaximum) or 0
            elseif type(values) == "table" then
                current = tonumber(values[1]) or 0
                maximum = tonumber(values[2]) or 0
                available = current
            else
                current = tonumber(values) or 0
                maximum = 0
                available = current
            end

            local isCurrentCharacter = data.guid == UnitGUID("player")
            if isCofferKeyShards and isCurrentCharacter and info then
                available = tonumber(info.quantity) or available
                current = tonumber(info.quantityEarnedThisWeek) or available
                maximum = tonumber(info.maxWeeklyQuantity) or maximum
            end

            local canConvertKeys = isCofferKeyShards
                and isCurrentCharacter
                and available > constants.COFFER_KEY_GLUE.MIN_SHARDS_EXCLUSIVE
                and not InCombatLockdown()
                and PlayerHasCofferKeyGlue()

            cell:ClearAllPoints()
            cell:SetPoint(
                "TOPLEFT",
                frame,
                "TOPLEFT",
                columnIndex * (cellWidth + cellGap),
                -(topOffset + (rowIndex * (layout.BAR_H + layout.BAR_GAP)))
            )
            cell:SetSize(cellWidth, layout.ICON_SIZE)
            cell.iconButton:ClearAllPoints()
            cell.iconButton:SetPoint("LEFT", cell, "LEFT", 0, 0)
            cell.iconButton:SetSize(layout.ICON_SIZE, layout.ICON_SIZE)
            cell.iconButton.texture:SetTexture(info and info.iconFileID or nil)
            cell.iconButton.currencyName = (info and info.name) or definition.fallbackName

            cell.bar:ClearAllPoints()
            cell.bar:SetPoint("LEFT", cell.iconButton, "RIGHT", 4, 0)
            cell.bar:SetSize(math.max(1, cellWidth - layout.ICON_SIZE - 4), layout.BAR_H)
            if canConvertKeys then
                SetTextureColor(cell.bar.background, constants.colors.vaultComplete)
                cell.bar:SetMinMaxValues(0, 1)
                cell.bar:SetValue(0)
            elseif maximum > 0 then
                SetTextureColor(cell.bar.background, constants.colors.barEmpty)
                cell.bar:SetMinMaxValues(0, maximum)
                cell.bar:SetValue(math.min(current, maximum))
            else
                SetTextureColor(cell.bar.background, constants.colors.barEmpty)
                cell.bar:SetMinMaxValues(0, 1)
                cell.bar:SetValue(1)
            end
            local statusTexture = cell.bar:GetStatusBarTexture()
            if statusTexture then
                SetTextureColor(statusTexture, constants.colors.currencyFill)
            end
            if canConvertKeys then
                cell.bar.text:SetText("Convert Keys")
            elseif definition.valueType == "flat" or maximum <= 0 then
                cell.bar.text:SetText(FormatWholeNumber(current))
            else
                cell.bar.text:SetText(("%s/%s"):format(
                    FormatWholeNumber(current),
                    FormatWholeNumber(maximum)
                ))
            end
            cell:Show()

            if canConvertKeys then
                self._cofferKeyGlueTarget = cell
                self._cofferKeyGlueShardCount = available
            end
        end
    end
    frame:Show()
end

function AltManager:ConfigureRow(row, guid, data, columnLayout)
    local layout = constants.layout
    row.guid = guid
    row.rowData = data
    row:SetSize(layout.FRAME_WIDTH - (2 * layout.PAD_X), layout.ROW_HEIGHT)
    self:ConfigureCharacterCell(row, data, columnLayout.character)
    self:ConfigureMythicCell(row, data, columnLayout.mplus)
    self:ConfigureVaultCell(row, data, columnLayout.vault)
    self:ConfigureCurrencyCell(row, data, columnLayout.currency)
    self:ConfigureRowInteractions(row)
    row:Show()
end

function AltManager:InitializeDrawer(drawer)
    if drawer.initialized then return end
    drawer.initialized = true
    drawer.texts = {}
    drawer.background = drawer:CreateTexture(nil, "BACKGROUND")
    drawer.background:SetAllPoints()
    drawer.background:SetColorTexture(0x17 / 255, 0x13 / 255, 0x1E / 255, 0.90)
    drawer.separator = drawer:CreateTexture(nil, "ARTWORK")
    drawer.separator:SetPoint("TOPLEFT", drawer, "TOPLEFT", 10, 0)
    drawer.separator:SetPoint("TOPRIGHT", drawer, "TOPRIGHT", -10, 0)
    drawer.separator:SetHeight(1)
    SetTextureColor(drawer.separator, constants.colors.drawerDivider)
end

function AltManager:ConfigureDrawer(drawer, data)
    local layout = constants.layout
    local innerWidth = layout.FRAME_WIDTH - (2 * layout.PAD_X)
    local textIndex = 0
    local cursor = 7

    for _, text in ipairs(drawer.texts) do
        text:Hide()
    end

    local function NextText(fontObject, size)
        textIndex = textIndex + 1
        local text = drawer.texts[textIndex]
        if not text then
            text = CreateText(drawer, fontObject, size)
            drawer.texts[textIndex] = text
        else
            SetFontSize(text, fontObject, size)
        end
        text:ClearAllPoints()
        text:SetJustifyH("LEFT")
        text:Show()
        return text
    end

    local function AddHeading(label)
        local text = NextText(GameFontNormalSmall, 10)
        text:SetPoint("TOPLEFT", drawer, "TOPLEFT", 12, -cursor)
        text:SetSize(innerWidth - 24, 14)
        text:SetText(label)
        SetFontColor(text, constants.colors.drawerHeading)
        cursor = cursor + 17
    end

    local function AddGrid(entries, columns)
        if #entries == 0 then return end
        local availableWidth = innerWidth - 24
        local columnWidth = availableWidth / columns
        local rowHeight = 16
        for index, entry in ipairs(entries) do
            local columnIndex = (index - 1) % columns
            local rowIndex = math.floor((index - 1) / columns)
            local text = NextText(GameFontHighlightSmall, 9.5)
            text:SetPoint(
                "TOPLEFT",
                drawer,
                "TOPLEFT",
                12 + (columnIndex * columnWidth),
                -(cursor + (rowIndex * rowHeight))
            )
            text:SetSize(columnWidth - 8, rowHeight)
            text:SetText(entry.text)
            SetFontColor(text, entry.color or constants.colors.body)
        end
        cursor = cursor + (math.ceil(#entries / columns) * rowHeight) + 7
    end

    local weeklyByKey = {}
    for _, weekly in ipairs(data.weeklies or {}) do
        weeklyByKey[weekly.key] = weekly
    end

    local STATUS_ORDER = { complete = 1, inprogress = 2, notstarted = 3, incomplete = 3 }
    local function AddWeeklyGroup(sectionKey, headingText, columns)
        if not self:IsRowVisible(sectionKey) then return end

        local section = FindSection(sectionKey)
        local entries = {}
        for _, child in ipairs((section and section.children) or {}) do
            if self:IsRowVisible(child.key) then
                local weekly = weeklyByKey[child.dataKey] or {}
                local status = weekly.status or "notstarted"
                if status == "incomplete" then status = "notstarted" end
                local style = STATUS_STYLES[status] or STATUS_STYLES.notstarted
                local progressText = ""
                if status == "inprogress" and weekly.progressType == "percent" then
                    local progress = tonumber(weekly.progress)
                    if progress then
                        progressText = (" (%d%%)"):format(progress)
                    end
                elseif status == "inprogress" and weekly.progressType == "count" then
                    local progress = tonumber(weekly.progress)
                    local required = tonumber(weekly.required)
                    if progress and required and required > 0 then
                        progressText = (" (%s/%s)"):format(
                            FormatWholeNumber(progress),
                            FormatWholeNumber(required)
                        )
                    end
                end
                entries[#entries + 1] = {
                    key = child.key,
                    label = child.label,
                    status = status,
                    alwaysLast = child.alwaysLast,
                    text = style.glyph .. " " .. child.label .. progressText,
                    color = status == "complete" and constants.colors.muted or constants.colors.body,
                }
            end
        end

        table.sort(entries, function(a, b)
            local aLast = a.alwaysLast and true or false
            local bLast = b.alwaysLast and true or false
            if aLast ~= bLast then return not aLast end
            local rankA = STATUS_ORDER[a.status] or 99
            local rankB = STATUS_ORDER[b.status] or 99
            if rankA ~= rankB then return rankA < rankB end
            if a.label ~= b.label then return a.label < b.label end
            return a.key < b.key
        end)

        if #entries > 0 then
            local completed = 0
            for _, entry in ipairs(entries) do
                if entry.status == "complete" then completed = completed + 1 end
            end
            AddHeading(("%s — %d/%d COMPLETE"):format(headingText, completed, #entries))
            AddGrid(entries, columns or 6)
        end
    end

    AddWeeklyGroup("world_events", "WORLD EVENTS", 6)
    AddWeeklyGroup("weekly_quests", "WEEKLY QUESTS", 6)

    if textIndex == 0 then
        return 0
    end

    local height = cursor + 3
    drawer:SetSize(innerWidth, height)
    drawer:Show()
    return height
end

function AltManager:ToggleRowDrawer(guid)
    if not guid then return end
    local config = MyAltManagerDB.config
    config.openRows = config.openRows or {}
    if config.openRows[guid] then
        config.openRows = {}
    else
        config.openRows = { [guid] = true }
    end
    self:RebuildUI()
end

function AltManager:GetSortedCharacters()
    local characters = {}
    local config = (MyAltManagerDB and MyAltManagerDB.config) or constants.config
    local minLevel = tonumber(config.MIN_LEVEL) or tonumber(constants.config.MIN_LEVEL) or 0
    local minItemLevel = tonumber(config.MIN_ITEM_LEVEL) or tonumber(constants.config.MIN_ITEM_LEVEL) or 0

    for guid, data in pairs((MyAltManagerDB and MyAltManagerDB.data) or {}) do
        local characterLevel = data and (tonumber(data.charLevel) or 0) or 0
        local itemLevel = data and (tonumber(data.ilevel) or 0) or 0
        if data
            and (tonumber(data.schema) or 0) >= constants.DATA_SCHEMA
            and characterLevel >= minLevel
            and itemLevel >= minItemLevel
        then
            characters[#characters + 1] = { guid = guid, data = data }
        end
    end

    table.sort(characters, function(a, b)
        local aName = tostring(a.data.name or ""):lower()
        local bName = tostring(b.data.name or ""):lower()
        if aName ~= bName then return aName < bName end

        local aRealm = tostring(a.data.realmName or ""):lower()
        local bRealm = tostring(b.data.realmName or ""):lower()
        if aRealm ~= bRealm then return aRealm < bRealm end
        return tostring(a.guid) < tostring(b.guid)
    end)
    return characters
end

function AltManager:RebuildUI()
    if not self.main_frame or not MyAltManagerDB then return end
    self:InitializeFrame()

    -- Detach the independent secure overlay before pooled rows move, then attach it
    -- to the logged-in character's eligible shard cell after layout is complete.
    self:DetachCofferKeyGlueCastBar()
    self._cofferKeyGlueTarget = nil
    self._cofferKeyGlueShardCount = 0
    self:UpdateCofferKeyGlueButton()

    local layout = constants.layout
    local frame = self.main_frame
    local innerWidth = layout.FRAME_WIDTH - (2 * layout.PAD_X)
    local columnLayout = self:GetColumnLayout()
    self:UpdateColumnHeaders(columnLayout)
    self:UpdateFooter()

    self.rowPool:ReleaseAll()
    self.drawerPool:ReleaseAll()

    local contentHeight = 0
    local characters = self:GetSortedCharacters()
    for _, character in ipairs(characters) do
        local row = self.rowPool:Acquire()
        self:InitializeRow(row)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 0, -contentHeight)
        self:ConfigureRow(row, character.guid, character.data, columnLayout)
        contentHeight = contentHeight + layout.ROW_HEIGHT

        local openRows = MyAltManagerDB.config.openRows or {}
        if openRows[character.guid] then
            local drawer = self.drawerPool:Acquire()
            self:InitializeDrawer(drawer)
            local drawerHeight = self:ConfigureDrawer(drawer, character.data)
            if drawerHeight > 0 then
                drawer:ClearAllPoints()
                drawer:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 0, -contentHeight)
                contentHeight = contentHeight + drawerHeight
            else
                self.drawerPool:Release(drawer)
            end
        end
    end

    local viewportHeight = math.max(1, contentHeight)
    frame.scrollChild:SetSize(innerWidth, math.max(contentHeight, viewportHeight))
    frame.scrollFrame:ClearAllPoints()
    frame.scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", layout.PAD_X, -(layout.TITLE_HEIGHT + layout.HEADER_HEIGHT))
    frame.scrollFrame:SetSize(innerWidth, viewportHeight)

    frame.footer:ClearAllPoints()
    frame.footer:SetPoint("TOPLEFT", frame.scrollFrame, "BOTTOMLEFT", -layout.PAD_X, 0)
    frame.footer:SetSize(layout.FRAME_WIDTH, layout.FOOTER_HEIGHT)

    frame:SetSize(
        layout.FRAME_WIDTH,
        layout.TITLE_HEIGHT + layout.HEADER_HEIGHT + viewportHeight + layout.FOOTER_HEIGHT
    )
    frame.background:SetAllPoints()
    self:MakeBorder(frame, 1)

    frame.scrollFrame:SetVerticalScroll(0)
    local scrollBar = frame.scrollFrame.ScrollBar or _G.AltManagerScrollFrameScrollBar
    if scrollBar then scrollBar:Hide() end
    self:RenderCofferKeyGlueCastDisplay()
    self:UpdateCofferKeyGlueButton()
end

function AltManager:HideInterface()
    self:StopFooterTicker()
    self:StopCofferKeyGlueCastDisplay()
    self._cofferKeyGlueTarget = nil
    self:HideCofferKeyGlueButton()
    self.main_frame:Hide()
end

function AltManager:ShowInterface()
    if self:CanCollectNow() then
        self:CollectAndStore()
    end
    MyAltManagerDB.config.openRows = {}
    self:RebuildUI()
    self.main_frame:Show()
    self:UpdateCofferKeyGlueButton()
    self:StartFooterTicker()
end

function AltManager:CreateRemoveButton(parent)
    local frame = CreateFrame("Button", nil, parent)
    frame:RegisterForClicks("LeftButtonUp")
    frame:SetScript("OnClick", function(button)
        GameTooltip:Hide()
        AltManager:RemoveCharacterByGuid(button.guid)
    end)
    frame:SetScript("OnEnter", function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText("Remove character")
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", GameTooltip_Hide)
    self:MakeRemoveTexture(frame)
    return frame
end

function AltManager:MakeRemoveTexture(frame)
    if not frame.remove_tex then
        frame.remove_tex = frame:CreateTexture(nil, "ARTWORK")
        frame.remove_tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        frame.remove_tex:SetAllPoints()
    end
    return frame.remove_tex
end

function AltManager:MakeBorderPart(frame, x, y, xoff, yoff, part)
    if not part then
        part = frame:CreateTexture(nil, "OVERLAY")
    end
    SetTextureColor(part, constants.colors.frameBorder)
    part:ClearAllPoints()
    part:SetPoint("TOPLEFT", frame, "TOPLEFT", xoff, yoff)
    part:SetSize(x, y)
    part:Show()
    return part
end

function AltManager:MakeBorder(frame, size)
    if size <= 0 then return end
    frame.borderTop = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, 0, frame.borderTop)
    frame.borderLeft = self:MakeBorderPart(frame, size, frame:GetHeight(), 0, 0, frame.borderLeft)
    frame.borderBottom = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, -frame:GetHeight() + size, frame.borderBottom)
    frame.borderRight = self:MakeBorderPart(frame, size, frame:GetHeight(), frame:GetWidth() - size, 0, frame.borderRight)
end

-- ------------------------------------------------------------
-- Reset time helpers
-- ------------------------------------------------------------

local function ColorizeText(text, color)
    local red = math.floor((color[1] or 1) * 255 + 0.5)
    local green = math.floor((color[2] or 1) * 255 + 0.5)
    local blue = math.floor((color[3] or 1) * 255 + 0.5)
    return ("|cff%02x%02x%02x%s|r"):format(red, green, blue, text)
end

local function FormatWeeklyResetDuration(seconds)
    seconds = math.floor(tonumber(seconds) or 0)
    if seconds <= 0 then return nil end

    local days = math.floor(seconds / 86400)
    if days > 0 then
        local hours = math.floor((seconds % 86400) / 3600)
        return ("%dd %02dh"):format(days, hours)
    end

    local hours = math.floor(seconds / 3600)
    if hours > 0 then
        local minutes = math.floor((seconds % 3600) / 60)
        return ("%dh %02dm"):format(hours, minutes)
    end

    return ("%dm"):format(math.max(1, math.floor(seconds / 60)))
end

local function FormatLocalClock(timestamp)
    local hour = tonumber(date("%H", timestamp))
    local minute = tonumber(date("%M", timestamp))
    if GameTime_GetFormattedTime and hour and minute then
        return GameTime_GetFormattedTime(hour, minute, true)
    end
    return date("%H:%M", timestamp)
end

local function GetCurseSurgeStatus()
    if not GetServerTime or not date then
        return nil
    end

    local now = GetServerTime()
    local schedule = constants.CURSE_SURGE
    local elapsed = (now - schedule.ANCHOR_EPOCH) % schedule.INTERVAL_SECONDS
    local surgeStartEpoch = now - elapsed
    if elapsed < schedule.STARTING_SECONDS then
        local secondsRemaining = schedule.STARTING_SECONDS - elapsed
        return "starting", secondsRemaining, now + secondsRemaining, elapsed, schedule.STARTING_SECONDS, surgeStartEpoch
    end

    if elapsed < schedule.ACTIVE_SECONDS then
        local activeElapsed = elapsed - schedule.STARTING_SECONDS
        local activeDuration = schedule.ACTIVE_SECONDS - schedule.STARTING_SECONDS
        local secondsRemaining = activeDuration - activeElapsed
        return "active", secondsRemaining, now + secondsRemaining, activeElapsed, activeDuration, surgeStartEpoch
    end

    local secondsUntil = schedule.INTERVAL_SECONDS - elapsed
    local waitingElapsed = elapsed - schedule.ACTIVE_SECONDS
    local waitingDuration = schedule.INTERVAL_SECONDS - schedule.ACTIVE_SECONDS
    return "waiting", secondsUntil, now + secondsUntil, waitingElapsed, waitingDuration, surgeStartEpoch
end

local function FormatCurseSurgeCountdown(seconds)
    seconds = math.max(0, math.ceil(tonumber(seconds) or 0))
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return ("%02d:%02d"):format(minutes, remainingSeconds)
end

local function FindScheduledCurseSurgeEvent(surgeStartEpoch)
    if not surgeStartEpoch or not C_EventScheduler or not C_EventScheduler.GetScheduledEvents then
        return nil
    end

    local scheduledEvents = C_EventScheduler.GetScheduledEvents()
    if type(scheduledEvents) ~= "table" then
        return nil
    end

    local schedule = constants.CURSE_SURGE
    local bestEvent
    local bestScore
    for _, eventInfo in ipairs(scheduledEvents) do
        local startTime = tonumber(eventInfo.startTime)
        local areaPoiID = tonumber(eventInfo.areaPoiID)
        if startTime and areaPoiID then
            local startDifference = math.abs(startTime - surgeStartEpoch)
            if startDifference <= schedule.EVENT_START_TOLERANCE_SECONDS then
                local duration = tonumber(eventInfo.duration)
                    or ((tonumber(eventInfo.endTime) or startTime) - startTime)
                local durationDifference = math.abs(duration - schedule.ACTIVE_SECONDS)
                local score = (startDifference * 10000) + durationDifference
                if not bestScore or score < bestScore then
                    bestEvent = eventInfo
                    bestScore = score
                end
            end
        end
    end

    return bestEvent
end

local function GetCurseSurgeEventName(areaPoiID)
    if not areaPoiID or not C_AreaPoiInfo or not C_AreaPoiInfo.GetAreaPOIInfo then
        return nil
    end

    -- This is the same nil-map lookup used by Blizzard's Events panel.
    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(nil, areaPoiID)
    return poiInfo and poiInfo.name or nil
end

-- Blizzard prefixes the POI name with "Curse Surge:". Strip that category label along
-- with punctuation so the scheduler text resolves to the short name and coordinates above.
local function NormalizeCurseSurgeEventName(name)
    local normalized = tostring(name or ""):lower():gsub("[^%w]", "")
    return (normalized:gsub("^cursesurge", ""))
end

local curseSurgeLocationsByName = {}
for _, location in ipairs(constants.CURSE_SURGE_LOCATIONS) do
    curseSurgeLocationsByName[NormalizeCurseSurgeEventName(location.name)] = location
    curseSurgeLocationsByName[NormalizeCurseSurgeEventName(location.event)] = location
    curseSurgeLocationsByName[NormalizeCurseSurgeEventName(location.target)] = location
end

local function GetCurseSurgeLocationByName(eventName)
    local normalized = NormalizeCurseSurgeEventName(eventName)
    if normalized == "" then return nil end
    return curseSurgeLocationsByName[normalized]
end

-- A map pin link an addon composes itself is stripped from SendChatMessage, but the link the
-- client generates for the waypoint it is actually holding survives. So place the waypoint,
-- read its link, then put the player's own waypoint and tracking back exactly as they were.
local function BuildCurseSurgeWaypointLink(location)
    if not C_Map or not C_Map.SetUserWaypoint or not C_Map.GetUserWaypointHyperlink
        or not UiMapPoint or not UiMapPoint.CreateFromCoordinates then
        return nil
    end
    if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(location.uiMapID) then
        return nil
    end

    local previousWaypoint = C_Map.GetUserWaypoint and C_Map.GetUserWaypoint() or nil
    local wasSuperTracking = C_SuperTrack and C_SuperTrack.IsSuperTrackingUserWaypoint
        and C_SuperTrack.IsSuperTrackingUserWaypoint() or false

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(
        location.uiMapID, location.x / 100, location.y / 100
    ))
    local link = C_Map.GetUserWaypointHyperlink()

    if previousWaypoint then
        C_Map.SetUserWaypoint(previousWaypoint)
    elseif C_Map.ClearUserWaypoint then
        C_Map.ClearUserWaypoint()
    end
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(wasSuperTracking)
    end

    return link
end

local function BuildCurseSurgeAnnouncement(minutes, eventName, location)
    local countdown = ("Curse Surge in %d minute%s"):format(minutes, minutes == 1 and "" or "s")
    if not eventName then
        return countdown .. "."
    end
    if not location then
        return ("%s - %s."):format(countdown, eventName)
    end

    -- Coordinates stay in the text so the message still reads if the pin cannot be built.
    local message = ("%s - %s at %.1f, %.1f"):format(countdown, eventName, location.x, location.y)
    local waypoint = BuildCurseSurgeWaypointLink(location)
    if not waypoint then
        return message .. "."
    end
    return ("%s %s"):format(message, waypoint)
end

function AltManager:RequestCurseSurgeEventData()
    if not C_EventScheduler or not C_EventScheduler.RequestEvents then return end

    local now = GetTime and GetTime() or 0
    if self._curseSurgeEventRequestTime and now - self._curseSurgeEventRequestTime < 10 then
        return
    end

    self._curseSurgeEventRequestTime = now
    C_EventScheduler.RequestEvents()
end

function AltManager:RefreshCurseSurgeEventName()
    if self._curseSurgeEventName or not self._curseSurgeAreaPoiID then return end
    self._curseSurgeEventName = GetCurseSurgeEventName(self._curseSurgeAreaPoiID)
end

function AltManager:StopCurseSurgeEventPriming()
    if self._curseSurgeEventPrimeTicker then
        self._curseSurgeEventPrimeTicker:Cancel()
        self._curseSurgeEventPrimeTicker = nil
    end
end

-- The scheduler only pushes data after a request, so ask at login rather than waiting for
-- the player to open the map or the events tab. The server answers asynchronously and the
-- POI name can lag behind it, so retry on a bounded schedule until the surge is named.
function AltManager:PrimeCurseSurgeEventData()
    self:StopCurseSurgeEventPriming()
    self:RefreshCurseSurgeEventCache()
    if self:HasResolvedCurseSurgeEvent() then return end

    local attemptsRemaining = constants.CURSE_SURGE.PRIME_ATTEMPTS
    self._curseSurgeEventPrimeTicker = C_Timer.NewTicker(constants.CURSE_SURGE.PRIME_INTERVAL_SECONDS, function()
        attemptsRemaining = attemptsRemaining - 1
        AltManager:RefreshCurseSurgeEventCache()
        if AltManager:HasResolvedCurseSurgeEvent() or attemptsRemaining <= 0 then
            AltManager:StopCurseSurgeEventPriming()
            AltManager:UpdateFooterCurseSurge()
        end
    end)
end

function AltManager:GetCurseSurgeEventStartEpoch(phase, phaseEndEpoch, surgeStartEpoch)
    -- While waiting, the surge we care about is the one that starts when the wait ends.
    return phase == "waiting" and phaseEndEpoch or surgeStartEpoch
end

-- True once the scheduler has named the surge the UI is currently counting down to.
function AltManager:HasResolvedCurseSurgeEvent()
    local phase, _, phaseEndEpoch, _, _, surgeStartEpoch = GetCurseSurgeStatus()
    if not phase then return false end

    local targetStartEpoch = self:GetCurseSurgeEventStartEpoch(phase, phaseEndEpoch, surgeStartEpoch)
    return self._curseSurgeEventStartEpoch == targetStartEpoch and self._curseSurgeEventName ~= nil
end

-- The display name for the surge being counted down to, in any phase. Prefers the short name
-- from the table, falling back to Blizzard's POI name for a surge we have no entry for.
function AltManager:GetActiveCurseSurgeEventName()
    if not self:HasResolvedCurseSurgeEvent() then return nil end

    local location = GetCurseSurgeLocationByName(self._curseSurgeEventName)
    return location and location.name or self._curseSurgeEventName
end

-- Resolves to the location of the surge the UI is currently naming, or nil while the
-- scheduled event is still unknown or its name is missing from constants.CURSE_SURGE_LOCATIONS.
function AltManager:GetActiveCurseSurgeLocation()
    if not self:HasResolvedCurseSurgeEvent() then return nil end
    return GetCurseSurgeLocationByName(self._curseSurgeEventName)
end

function AltManager:RefreshCurseSurgeEventCache()
    local phase, _, phaseEndEpoch, _, _, surgeStartEpoch = GetCurseSurgeStatus()
    if not phase then return end

    local targetStartEpoch = self:GetCurseSurgeEventStartEpoch(phase, phaseEndEpoch, surgeStartEpoch)
    if self._curseSurgeEventStartEpoch == targetStartEpoch
        and self._curseSurgeAreaPoiID and self._curseSurgeEventName then
        return
    end

    local eventInfo = FindScheduledCurseSurgeEvent(targetStartEpoch)
    if not eventInfo then
        self:RequestCurseSurgeEventData()
        return
    end

    self._curseSurgeEventStartEpoch = targetStartEpoch
    self._curseSurgeAreaPoiID = eventInfo.areaPoiID
    self._curseSurgeEventName = nil
    C_Timer.After(0, function()
        AltManager:RefreshCurseSurgeEventName()
    end)
end

-- Keep the scheduler lookup in its own timer callback. Event timestamps can be
-- secret in 12.x, while SetSuperTrackedMapPin must run outside that tainted path.
function AltManager:FocusStartingCurseSurge(surgeStartEpoch)
    if not surgeStartEpoch or self._curseSurgeFocusedStartEpoch == surgeStartEpoch then return end
    if not C_SuperTrack or not C_SuperTrack.SetSuperTrackedMapPin
        or not Enum or not Enum.SuperTrackingMapPinType
        or not Enum.SuperTrackingMapPinType.AreaPOI then
        return
    end

    local areaPoiID = self._curseSurgeEventStartEpoch == surgeStartEpoch
        and self._curseSurgeAreaPoiID or nil
    if not areaPoiID then return end

    local focusedAreaPoiID
    if C_SuperTrack.GetSuperTrackedMapPin then
        local _, currentAreaPoiID = C_SuperTrack.GetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI)
        focusedAreaPoiID = currentAreaPoiID
    end
    if focusedAreaPoiID ~= areaPoiID then
        C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, areaPoiID)
    end
    self._curseSurgeFocusedStartEpoch = surgeStartEpoch
end

-- True only when the player's waypoint is both sitting on this surge and being super-tracked.
-- The stored position can be quantised, so match within a fraction of the map far smaller
-- than the gap between any two surge spawn points.
local CURSE_SURGE_WAYPOINT_EPSILON = 0.005

function AltManager:IsTrackingCurseSurgeLocation()
    local location = self:GetActiveCurseSurgeLocation()
    if not location then return false end

    if not C_SuperTrack or not C_SuperTrack.IsSuperTrackingUserWaypoint
        or not C_SuperTrack.IsSuperTrackingUserWaypoint() then
        return false
    end

    if not C_Map or not C_Map.GetUserWaypointPositionForMap then return false end
    local position = C_Map.GetUserWaypointPositionForMap(location.uiMapID)
    if not position then return false end

    local x, y = position:GetXY()
    if not x or not y then return false end

    return math.abs(x - (location.x / 100)) <= CURSE_SURGE_WAYPOINT_EPSILON
        and math.abs(y - (location.y / 100)) <= CURSE_SURGE_WAYPOINT_EPSILON
end

-- Toggles a map pin on the surge's spawn point, using the same call pairs Blizzard makes for
-- its own hardcoded waypoints and its map pin. Deliberately does not touch the surge tracker.
function AltManager:TrackCurseSurgeLocation()
    local location = self:GetActiveCurseSurgeLocation()
    if not location or not C_Map then return end

    if self:IsTrackingCurseSurgeLocation() then
        if C_Map.ClearUserWaypoint then
            C_Map.ClearUserWaypoint()
        end
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            C_SuperTrack.SetSuperTrackedUserWaypoint(false)
        end
        return
    end

    if not C_Map.SetUserWaypoint or not UiMapPoint or not UiMapPoint.CreateFromCoordinates then
        return
    end

    if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(location.uiMapID) then
        print("MyAltManager: cannot place a map pin for the Curse Surge from here.")
        return
    end

    C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(location.uiMapID, location.x / 100, location.y / 100))
    if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    end
end

function AltManager:IsCurseSurgeAnnounceEnabled()
    local config = MyAltManagerDB and MyAltManagerDB.config
    return config ~= nil and config.curse_surge_announce == true
end

-- Goes to guild chat. With no guild to send to it prints locally instead, so the
-- announcement is never silently lost on a guildless character.
function AltManager:SendCurseSurgeAnnouncement(message)
    local sendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
    if sendChatMessage and IsInGuild and IsInGuild() then
        sendChatMessage(message, "GUILD")
        return
    end

    print("MyAltManager: " .. message)
end

-- Fires at most once per surge, keyed on the epoch that surge starts. The key is saved so a
-- reload, a relog, or swapping characters mid-countdown cannot repeat an announcement.
function AltManager:CheckCurseSurgeAnnouncement()
    if not self:IsCurseSurgeAnnounceEnabled() then return end

    local config = MyAltManagerDB and MyAltManagerDB.config
    if not config then return end

    local phase, secondsUntil, phaseEndEpoch = GetCurseSurgeStatus()
    -- Only the countdown is announced; once a surge starts the lead time has passed.
    if phase ~= "waiting" then return end

    local schedule = constants.CURSE_SURGE
    if secondsUntil > schedule.ANNOUNCE_LEAD_SECONDS then return end
    if config.curse_surge_announced_start_epoch == phaseEndEpoch then return end

    -- Chat output and map pin links are what the player acts on next, and acting on them in
    -- combat runs into restricted actions, so hold the message until they are out of it.
    if InCombatLockdown() or UnitAffectingCombat("player") then return end

    if not self:HasResolvedCurseSurgeEvent() then
        self:RefreshCurseSurgeEventCache()
    end

    -- Give the scheduler the first minute of the window to name the surge before settling
    -- for a bare countdown, so a slow lookup does not cost the announcement its location.
    local location = self:GetActiveCurseSurgeLocation()
    if not location and secondsUntil > schedule.ANNOUNCE_FALLBACK_SECONDS then return end

    config.curse_surge_announced_start_epoch = phaseEndEpoch
    self:SendCurseSurgeAnnouncement(BuildCurseSurgeAnnouncement(
        math.max(1, math.ceil(secondsUntil / 60)),
        self:GetActiveCurseSurgeEventName(),
        location
    ))
end

function AltManager:StopCurseSurgeAnnounceTicker()
    if self._curseSurgeAnnounceTicker then
        self._curseSurgeAnnounceTicker:Cancel()
        self._curseSurgeAnnounceTicker = nil
    end
end

-- The announcement has to keep time with no frame open, so it runs on its own ticker.
function AltManager:ApplyCurseSurgeAnnounceSetting()
    self:StopCurseSurgeAnnounceTicker()
    if not self:IsCurseSurgeAnnounceEnabled() then return end

    self._curseSurgeAnnounceTicker = C_Timer.NewTicker(constants.CURSE_SURGE.ANNOUNCE_POLL_SECONDS, function()
        AltManager:CheckCurseSurgeAnnouncement()
    end)
    self:CheckCurseSurgeAnnouncement()
end

function AltManager:ApplyCurseSurgeTrackerSettings()
    local tracker = self.curseSurgeTracker
    local config = MyAltManagerDB and MyAltManagerDB.config
    if not tracker or not config then return end

    local defaults = constants.CURSE_SURGE_TRACKER
    local width = math.max(220, math.min(600, tonumber(config.curse_surge_tracker_width) or defaults.WIDTH))
    local height = math.max(20, math.min(60, tonumber(config.curse_surge_tracker_height) or defaults.HEIGHT))
    local fontSize = math.max(9, math.min(24, tonumber(config.curse_surge_tracker_font_size) or defaults.FONT_SIZE))
    local opacity = math.max(0, math.min(100, tonumber(config.curse_surge_tracker_background_opacity) or defaults.BACKGROUND_OPACITY)) / 100

    tracker:SetSize(width, height)
    tracker.icon:SetSize(height, height)
    tracker.background:SetColorTexture(0x18 / 255, 0x1A / 255, 0x1B / 255, opacity)
    SetFontSize(tracker.statusText, GameFontNormal, fontSize, "OUTLINE")
    SetFontSize(tracker.timerText, GameFontNormal, fontSize, "OUTLINE")
    local timerWidth = math.max(66, math.ceil(fontSize * 4.5))
    tracker.timerText:SetWidth(timerWidth)
    tracker.statusText:ClearAllPoints()
    tracker.statusText:SetPoint("TOPLEFT", tracker, "TOPLEFT", height + 8, 0)
    tracker.statusText:SetPoint("BOTTOMRIGHT", tracker, "BOTTOMRIGHT", -(timerWidth + 16), 0)
end

function AltManager:UpdateCurseSurgeTracker()
    local tracker = self.curseSurgeTracker
    if not tracker or not tracker:IsShown() then return end

    local phase, secondsRemaining, _, phaseElapsed, phaseDuration, surgeStartEpoch = GetCurseSurgeStatus()
    if phase == nil then
        tracker.statusText:SetText("Curse Surge Unavailable")
        tracker.timerText:SetText("--:--")
        tracker:SetMinMaxValues(0, 1)
        tracker:SetValue(0)
        return
    end

    -- Named per phase where the scheduler has told us which surge it is, generic until then.
    local eventName = self:GetActiveCurseSurgeEventName()
    local statusText
    if phase == "starting" then
        statusText = eventName and ("Starting: " .. eventName) or "Curse Surge Starting"
    elseif phase == "active" then
        statusText = eventName and ("Active: " .. eventName) or "Curse Surge Active"
    else
        statusText = eventName and ("Next: " .. eventName) or "Next Curse Surge"
    end

    tracker.statusText:SetText(statusText)
    tracker.timerText:SetText(FormatCurseSurgeCountdown(secondsRemaining))
    tracker:SetMinMaxValues(0, math.max(1, phaseDuration or 1))
    if phase == "waiting" then
        tracker:SetValue(math.max(0, phaseElapsed or 0))
    else
        tracker:SetValue(math.max(0, secondsRemaining or 0))
        if phase == "starting" then
            self:FocusStartingCurseSurge(surgeStartEpoch)
        end
    end
end


function AltManager:StopCurseSurgeTrackerTicker()
    if self._curseSurgeTrackerTicker then
        self._curseSurgeTrackerTicker:Cancel()
        self._curseSurgeTrackerTicker = nil
    end
    if self._curseSurgeEventResolverTicker then
        self._curseSurgeEventResolverTicker:Cancel()
        self._curseSurgeEventResolverTicker = nil
    end
end

function AltManager:StartCurseSurgeTrackerTicker()
    self:StopCurseSurgeTrackerTicker()
    self:UpdateCurseSurgeTracker()
    C_Timer.After(0, function()
        AltManager:RefreshCurseSurgeEventCache()
    end)
    self._curseSurgeTrackerTicker = C_Timer.NewTicker(1, function()
        AltManager:UpdateCurseSurgeTracker()
    end)
    self._curseSurgeEventResolverTicker = C_Timer.NewTicker(5, function()
        AltManager:RefreshCurseSurgeEventCache()
    end)
end

function AltManager:IsCurseSurgeTrackerShown()
    local config = MyAltManagerDB and MyAltManagerDB.config
    local guid = UnitGUID("player")
    if not config or not guid then return false end

    config.curse_surge_tracker_shown_by_character = config.curse_surge_tracker_shown_by_character or {}

    -- Migrate the former account-wide value to the first character loaded after this update.
    if config.curse_surge_tracker_shown ~= nil then
        if config.curse_surge_tracker_shown_by_character[guid] == nil then
            config.curse_surge_tracker_shown_by_character[guid] = config.curse_surge_tracker_shown and true or false
        end
        config.curse_surge_tracker_shown = nil
    end

    return config.curse_surge_tracker_shown_by_character[guid] == true
end

function AltManager:SetCurseSurgeTrackerShown(shown)
    local config = MyAltManagerDB and MyAltManagerDB.config
    local guid = UnitGUID("player")
    if not config or not guid then return end

    config.curse_surge_tracker_shown_by_character = config.curse_surge_tracker_shown_by_character or {}
    config.curse_surge_tracker_shown_by_character[guid] = shown and true or false
    config.curse_surge_tracker_shown = nil
    self:InitializeCurseSurgeTracker()
    if self:IsCurseSurgeTrackerShown() then
        self:ApplyCurseSurgeTrackerSettings()
        self.curseSurgeTracker:Show()
        self:StartCurseSurgeTrackerTicker()
    else
        self:StopCurseSurgeTrackerTicker()
        self.curseSurgeTracker:Hide()
    end
end

function AltManager:ToggleCurseSurgeTracker()
    self:SetCurseSurgeTrackerShown(not self:IsCurseSurgeTrackerShown())
end

function AltManager:InitializeCurseSurgeTracker()
    if self.curseSurgeTracker then return end

    local tracker = CreateFrame("StatusBar", "MyAltManagerCurseSurgeTracker", UIParent)
    self.curseSurgeTracker = tracker
    tracker:SetFrameStrata("HIGH")
    tracker:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
    tracker:SetStatusBarColor(0x20 / 255, 0x55 / 255, 0x38 / 255, 1)
    tracker:SetMinMaxValues(0, 1)
    tracker:SetValue(0)
    tracker:SetMovable(true)
    tracker:SetClampedToScreen(true)
    tracker:EnableMouse(true)
    tracker:RegisterForDrag("LeftButton")

    tracker.background = tracker:CreateTexture(nil, "BACKGROUND")
    tracker.background:SetAllPoints()

    tracker.icon = tracker:CreateTexture(nil, "OVERLAY", nil, 6)
    tracker.icon:SetTexture("Interface\\Icons\\inv_ability_poison_groundstate")
    tracker.icon:SetDrawLayer("OVERLAY", 6)
    tracker.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    tracker.icon:SetPoint("LEFT", tracker, "LEFT", 0, 0)

    tracker.iconDivider = tracker:CreateTexture(nil, "OVERLAY", nil, 7)
    SetTextureColor(tracker.iconDivider, constants.colors.barBorder)
    tracker.iconDivider:SetPoint("TOPLEFT", tracker.icon, "TOPRIGHT", 0, -1)
    tracker.iconDivider:SetPoint("BOTTOMLEFT", tracker.icon, "BOTTOMRIGHT", 0, 1)
    tracker.iconDivider:SetWidth(1)

    tracker.statusText = CreateText(tracker, GameFontNormal, constants.CURSE_SURGE_TRACKER.FONT_SIZE)
    tracker.statusText:SetJustifyH("LEFT")
    SetFontColor(tracker.statusText, constants.colors.brightText)

    tracker.timerText = CreateText(tracker, GameFontNormal, constants.CURSE_SURGE_TRACKER.FONT_SIZE)
    tracker.timerText:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", -10, 0)
    tracker.timerText:SetPoint("BOTTOMRIGHT", tracker, "BOTTOMRIGHT", -10, 0)
    tracker.timerText:SetJustifyH("RIGHT")
    SetFontColor(tracker.timerText, constants.colors.brightText)

    CreateInsetBorder(tracker)
    for _, borderPart in ipairs(tracker.borderParts) do
        borderPart:SetDrawLayer("OVERLAY", 7)
    end
    -- isDragging is armed on mouse down and only set by a real drag, so releasing after
    -- repositioning the bar never counts as a click. Either firing order is safe.
    tracker:SetScript("OnMouseDown", function(frame)
        frame.isDragging = false
    end)
    tracker:SetScript("OnDragStart", function(frame)
        frame.isDragging = true
        frame:StartMoving()
    end)
    tracker:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = frame:GetPoint(1)
        MyAltManagerDB.config.curse_surge_tracker_point = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end)
    tracker:SetScript("OnMouseUp", function(frame, button)
        if frame.isDragging then
            frame.isDragging = false
            return
        end
        if button ~= "LeftButton" then return end
        AltManager:TrackCurseSurgeLocation()
    end)

    local savedPoint = MyAltManagerDB.config.curse_surge_tracker_point
    if type(savedPoint) == "table" and savedPoint.point then
        tracker:SetPoint(
            savedPoint.point,
            UIParent,
            savedPoint.relativePoint or savedPoint.point,
            tonumber(savedPoint.x) or 0,
            tonumber(savedPoint.y) or 0
        )
    else
        tracker:SetPoint("CENTER", UIParent, "CENTER", 0, 180)
    end

    self:ApplyCurseSurgeTrackerSettings()
    if self:IsCurseSurgeTrackerShown() then
        tracker:Show()
        self:StartCurseSurgeTrackerTicker()
    else
        tracker:Hide()
    end
end

-- Coordinates take the title gold; the label around them stays the footer's own colour.
function AltManager:RenderFooterCurseSurgeLocation()
    local footerLocation = self.main_frame and self.main_frame.footerCurseSurgeLocation
    local location = footerLocation and footerLocation.surgeLocation
    if not location then return end

    local color = footerLocation.isHighlighted and constants.colors.brightText or constants.colors.titleText
    footerLocation.text:SetText((" - Location: %s"):format(
        ColorizeText(("%.1f, %.1f"):format(location.x, location.y), color)
    ))
end

function AltManager:UpdateFooterCurseSurge()
    local footerCurseSurge = self.main_frame and self.main_frame.footerCurseSurge
    local footerLocation = self.main_frame and self.main_frame.footerCurseSurgeLocation
    if not footerCurseSurge then return end

    local phase, secondsUntil, nextEpoch = GetCurseSurgeStatus()
    if phase == nil then
        footerCurseSurge:Hide()
        if footerLocation then footerLocation:Hide() end
        return
    end

    local icon = "|TInterface\\Icons\\inv_ability_poison_groundstate:12:12:0:0|t"
    if phase == "starting" then
        footerCurseSurge.text:SetText(("%s Curse Surge Starting"):format(icon))
    elseif phase == "active" then
        footerCurseSurge.text:SetText(("%s Curse Surge %s"):format(
            icon,
            ColorizeText("Active", constants.colors.success)
        ))
    else
        footerCurseSurge.text:SetText(("%s Curse Surge in %d minutes (%s)"):format(
            icon,
            math.ceil(secondsUntil / 60),
            FormatLocalClock(nextEpoch)
        ))
    end
    footerCurseSurge:SetWidth(math.max(1, math.ceil(footerCurseSurge.text:GetStringWidth()) + 1))
    footerCurseSurge:Show()

    if not footerLocation then return end

    local location = self:GetActiveCurseSurgeLocation()
    footerLocation.surgeLocation = location
    if not location then
        footerLocation:Hide()
        return
    end

    self:RenderFooterCurseSurgeLocation()
    footerLocation:SetWidth(math.max(1, math.ceil(footerLocation.text:GetStringWidth()) + 1))
    footerLocation:Show()
end

function AltManager:UpdateFooterReset()
    local footerReset = self.main_frame and self.main_frame.footerReset
    if not footerReset then return end

    local duration = FormatWeeklyResetDuration(C_DateAndTime.GetSecondsUntilWeeklyReset())
    if not duration then
        footerReset:Hide()
        return
    end

    footerReset:SetText("Weekly reset in " .. ColorizeText(duration, constants.colors.brightText))
    footerReset:Show()
end

function AltManager:UpdateFooter()
    self:UpdateFooterCurseSurge()
    self:UpdateFooterReset()
end

function AltManager:StopFooterTicker()
    if self._footerTicker then
        self._footerTicker:Cancel()
        self._footerTicker = nil
    end
    if self._footerEventResolverTicker then
        self._footerEventResolverTicker:Cancel()
        self._footerEventResolverTicker = nil
    end
end

function AltManager:StartFooterTicker()
    self:StopFooterTicker()
    C_Timer.After(0, function()
        AltManager:RefreshCurseSurgeEventCache()
    end)
    self._footerTicker = C_Timer.NewTicker(30, function()
        AltManager:UpdateFooter()
    end)
    -- The scheduled event and its POI name arrive asynchronously, so poll for the surge
    -- location faster than the 30 second footer refresh and redraw once it resolves.
    self._footerEventResolverTicker = C_Timer.NewTicker(5, function()
        AltManager:RefreshCurseSurgeEventCache()
        AltManager:UpdateFooterCurseSurge()
    end)
end

function AltManager:GetNextWeeklyResetTime()
    local seconds = C_DateAndTime.GetSecondsUntilWeeklyReset()
    if not seconds or seconds <= 0 then return nil end
    return time() + seconds
end

function AltManager:GetLastWeeklyResetTime()
    local nextResetAt = self:GetNextWeeklyResetTime()
    local lastResetAt = nextResetAt and (nextResetAt - constants.WEEK_SECONDS)
    local db = MyAltManagerDB
    if db then
        db.meta = db.meta or {}
        local storedAt = tonumber(db.meta.lastWeeklyResetAt)
        if lastResetAt and (not storedAt or lastResetAt > storedAt) then
            db.meta.lastWeeklyResetAt = lastResetAt
        elseif not lastResetAt then
            lastResetAt = storedAt
        end
    end
    return lastResetAt
end
