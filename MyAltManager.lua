local _, AltManager = ...

_G["AltManager"] = AltManager

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 2020-10-14
-- updates for Dragonflight, and The War Within by: Faith - Frostmourne, 2021-2024
-- Last edit: 2023-11-12
-- updates for Midnight pre-patch 12.0 by: Faith - Frostmourne, 2026-01-21

local sizey = 535 -- initial default, recalculated after CreateContent
local font_height = 14
local xoffset = 0
local yoffset = 50
local addon = "MyAltManager"

local per_alt_x = 150
local ilvl_text_size = 12
local remove_button_size = 16
local min_x_size = 300

local constants = {}

constants.config = {}
constants.config.MIN_LEVEL = 80
constants.config.MIN_ITEM_LEVEL = 0 -- controlled via settings panel
constants.config.COLLECT_MIN_INTERVAL_SECONDS = 1.5
constants.config.MYTHICPLUS_METADATA_MIN_INTERVAL_SECONDS = 20

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
    TIER_SET = "Tier (S1)",
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
    RADIANT_SPARKS = "Radiant Sparks |TInterface\\Icons\\inv_enchanting_dust_color5:12:12:0:0|t",
    HIDDEN_TROVE = "Hidden Trove (Delves)",
    RESTORED_COFFER_KEY = "Bountiful Keys |TInterface\\Icons\\inv_10_blacksmithing_consumable_key_color1:12:12:0:0|t",
    COFFER_KEY_SHARDS = "Coffer Key Shards |TInterface\\Icons\\inv_gizmo_hardenedadamantitetube:12:12:0:0|t",
    VOIDLIGHT_MARL = "Voidlight Marl |TInterface\\Icons\\inv_112_raidtrinkets_voidprism:12:12:0:0|t",
    WEEKLY_META_QUEST = "Weekly Meta Quest",
    SATHTHERIL_SOIREE = "Sath'theril Soiree",
    SPECIAL_ASSIGNMENT = "Special Assignment",
    ABUNDANT_OFFERINGS = "Abundant Offerings",
    LEGENDS_OF_THE_HARANIR = "Legends of the Haranir",
    STORMARIAN_ASSAULT = "Stormarian Assault",
    NIGHTMARISH_TASK = "A Nightmarish Task",
    GREAT_VAULT_REWARDS = "Great Vault",
    WORLD_BOSS = "World Boss",
    PVP = "PVP",
    SHARD_OF_DUNDUN = "Shard of Dundun |TInterface\\Icons\\inv_ore_feliron:12:12:0:0|t",
    REMNANT_OF_ANGUISH = "Remnant of Anguish |TInterface\\Icons\\inv_10_elementalcombinedfoozles_blood:12:12:0:0|t",
    UNALLOYED_ABUNDANCE = "Unalloyed Abundance |TInterface\\Icons\\inv_10_gathering_bioluminescentspores_large:12:12:0:0|t",
    NEBULOUS_VOIDCORE = "Nebulous Cores",
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
        key = "weekly_quests", label = "Weekly Quests",
        keys = { "weekly_quests", "weekly_meta_quest", "special_assignment", "saththeril_soiree", "abundant_offerings", "legends_of_the_haranir", "stormarian_assault", "hidden_trove", "nightmarish_task", "world_boss" },
        children = {
            { key = "weekly_meta_quest",       label = "Weekly Meta Quest" },
            { key = "special_assignment",      label = "Special Assignment" },
            { key = "saththeril_soiree",       label = "Sath'theril Soiree" },
            { key = "abundant_offerings",      label = "Abundant Offerings" },
            { key = "legends_of_the_haranir",  label = "Legends of the Haranir" },
            { key = "stormarian_assault",      label = "Stormarian Assault" },
            { key = "hidden_trove",            label = "Hidden Trove" },
            { key = "nightmarish_task",        label = "A Nightmarish Task" },
            { key = "world_boss",              label = "World Boss" },
        },
    },
    {
        key = "currencies", label = "Currencies",
        keys = { "currencies", "radiantSparks", "adventurer_crests", "veteran_crests", "champion_crests", "hero_crests", "myth_crests", "restored_coffer_keys", "coffer_key_shards", "undercoin", "anglerPearls", "voidlightMarl", "shardOfDundun", "remnantOfAnguish", "unalloyedAbundance", "untaintedManaCrystal", "fieldAccolade", "luminousDust", "brimmingArcana" },
        children = {
            { key = "radiantSparks",       label = "Radiant Sparks",      icon = constants.labels.RADIANT_SPARKS:match("|T[^|]-|t") },
            { key = "adventurer_crests",   label = "Adventurer Crests",   icon = constants.labels.ADVENTURER_CRESTS:match("|T[^|]-|t") },
            { key = "veteran_crests",      label = "Veteran Crests",      icon = constants.labels.VETERAN_CRESTS:match("|T[^|]-|t") },
            { key = "champion_crests",     label = "Champion Crests",     icon = constants.labels.CHAMPION_CRESTS:match("|T[^|]-|t") },
            { key = "hero_crests",         label = "Hero Crests",         icon = constants.labels.HERO_CRESTS:match("|T[^|]-|t") },
            { key = "myth_crests",         label = "Myth Crests",         icon = constants.labels.MYTH_CRESTS:match("|T[^|]-|t") },
            { key = "restored_coffer_keys", label = "Bountiful Keys",     icon = constants.labels.RESTORED_COFFER_KEY:match("|T[^|]-|t") },
            { key = "coffer_key_shards",   label = "Coffer Key Shards",   icon = constants.labels.COFFER_KEY_SHARDS:match("|T[^|]-|t") },
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

constants.section_lookup = {}
constants.child_lookup = {}
for _, section in ipairs(constants.sections) do
    for _, k in ipairs(section.keys) do
        constants.section_lookup[k] = section.key
    end
    if section.children then
        for _, child in ipairs(section.children) do
            constants.child_lookup[child.key] = section.key
        end
    end
end

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

constants.RAID_ILVL = {
    [1] = "D:N",
    [2] = "D:H",
    [3] = "R:10N",
    [4] = "R:25N",
    [5] = "R:10H",
    [6] = "R:25H",
    [7] = "233", -- LFR
    [8] = "D:CM",
    [9] = "R:40",
    [14] = "246", -- Normal
    [15] = "259", -- Heroic
    [16] = "272", -- Mythic
    [17] = "233", -- LFR
    [23] = "D:M",
    [24] = "D:TW",
    [33] = "R:TW",
    [202] = "Story",
}

constants.DELVE_ILVL = {
    [1]  = "233", -- Prey: Normal
    [2]  = "237",
    [3]  = "240",
    [4]  = "243",
    [5]  = "246", -- Prey: Heroic
    [6]  = "253",
    [7]  = "256",
    [8]  = "259", -- Prey: Nightmare
    [9]  = "259",
    [10] = "259",
    [11] = "259",
    [12] = "263",
    [13] = "269",
}

constants.DUNGEON_ILVL = {
    [0]  = "256",
    [1]  = "256",
    [2]  = "259",
    [3]  = "259",
    [4]  = "263",
    [5]  = "263",
    [6]  = "266",
    [7]  = "269",
    [8]  = "269",
    [9]  = "269",
    [10] = "272",
}

constants.currencies = {
    conquest = 1602,
    honor = 1792,
    bloodyTokens = 2123,
    catalyst = 3378,
    undercoin = 2803,
    anglerPearls = 3373,
    voidlightMarl = 3316,
    restored_coffer_keys = 3028,
    cofferKeyShards = 3310,
    adventurer_crests = 3383,
    veteran_crests = 3341,
    champion_crests = 3343,
    hero_crests = 3345,
    myth_crests = 3347,
    radiantSparks = 3212,
    shardOfDundun = 3376,
    remnantOfAnguish = 3392,
    unalloyedAbundance = 3377,
    nebulousVoidcore = 3418,
    untaintedManaCrystal = 3356,
    fieldAccolade = 3405,
    luminousDust = 3385,
    brimmingArcana = 3379,
}

constants.TIER_SETS = {
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

constants.TIER_SLOTS = {
    [1] = "Helm",
    [3] = "Shoulders",
    [5] = "Chest",
    [7] = "Pants",
    [10] = "Gloves",
}

constants.VERSION = "12.0.5.0"

-- ------------------------------------------------------------
-- Utility helpers
-- ------------------------------------------------------------

local function spairs(t, order)
    if not t then return end
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

local function true_numel(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end

local function GetCurrencyAmount(id)
    local info = C_CurrencyInfo.GetCurrencyInfo(id)
    return info and info.quantity or 0
end

local function GetMonotonicTime()
    if GetTimePreciseSec then
        return GetTimePreciseSec()
    end
    return GetTime()
end

local stripped_label_cache = {}
local function StripInlineIconMarkup(label)
    if not label then return " " end

    local cached = stripped_label_cache[label]
    if cached then
        return cached
    end

    local stripped = label:gsub("|T[^|]-|t", "")
    stripped = stripped:gsub("%s+:", ":")
    stripped = stripped:match("^%s*(.-)%s*$")
    if stripped == "" then
        stripped = " "
    end

    stripped_label_cache[label] = stripped
    return stripped
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
        local data = self:CollectData()
        self:StoreData(data)
        self._lastCollectAt = GetMonotonicTime()
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
    for k in pairs(constants.DUNGEONS) do
        C_MythicPlus.RequestMapInfo(k)
    end

    local maps = C_ChallengeMode.GetMapTable() or {}
    for idx = 1, #maps do
        C_ChallengeMode.RequestLeaders(maps[idx])
    end

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

    db.config.MIN_ITEM_LEVEL = level
    constants.config.MIN_ITEM_LEVEL = level

    print(("MyAltManager: MIN_ITEM_LEVEL set to %d"):format(level))
end

function AltManager:LoadConfigFromDB()
    local db = MyAltManagerDB
    db.config = db.config or {}
    db.visibility = db.visibility or {}

    if db.config.MIN_ITEM_LEVEL == nil then
        db.config.MIN_ITEM_LEVEL = 0
    end
    if db.config.MIN_LEVEL == nil then
        db.config.MIN_LEVEL = 80
    end
    if db.config.show_icons == nil then
        db.config.show_icons = true
    end

    constants.config.MIN_ITEM_LEVEL = tonumber(db.config.MIN_ITEM_LEVEL) or 0
    constants.config.MIN_LEVEL = tonumber(db.config.MIN_LEVEL) or 80
end

function AltManager:RegisterSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("MyAltManager")
    self.settingsCategory = category

    local function RebuildIfNeeded()
        if AltManager.columns_table then
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
        end)
    end

    -- Toggle Icons checkbox
    do
        local iconSetting = Settings.RegisterAddOnSetting(
            category, "MyAltManager_ShowIcons", "show_icons",
            MyAltManagerDB.config, Settings.VarType.Boolean,
            "Show Icons", true
        )
        Settings.CreateCheckbox(category, iconSetting, "Show or hide icon textures in labels.")
        Settings.SetOnValueChangedCallback("MyAltManager_ShowIcons", function(_, _, value)
            MyAltManagerDB.config.show_icons = value
            RebuildIfNeeded()
        end)
    end

    -- Section toggles with child sub-toggles
    for _, section in ipairs(constants.sections) do
        local parentVarName = "MyAltManager_Show_" .. section.key
        local parentSetting = Settings.RegisterAddOnSetting(
            category, parentVarName, section.key,
            MyAltManagerDB.visibility, Settings.VarType.Boolean,
            "Show " .. section.label, true
        )
        local parentInitializer = Settings.CreateCheckbox(category, parentSetting, "Toggle visibility of the " .. section.label .. " section.")
        Settings.SetOnValueChangedCallback(parentVarName, function(_, _, value)
            MyAltManagerDB.visibility[section.key] = value
            RebuildIfNeeded()
        end)

        -- Child toggles
        if section.children then
            for _, child in ipairs(section.children) do
                local childVarName = "MyAltManager_Show_" .. child.key
                local settingsIcon = child.icon and child.icon:gsub(":12:12:", ":20:20:") or nil
                local displayLabel = settingsIcon and (settingsIcon .. " " .. child.label) or child.label
                local childSetting = Settings.RegisterAddOnSetting(
                    category, childVarName, child.key,
                    MyAltManagerDB.visibility, Settings.VarType.Boolean,
                    displayLabel, true
                )
                local childInitializer = Settings.CreateCheckbox(category, childSetting, "Toggle visibility of " .. child.label .. ".")
                childInitializer:SetParentInitializer(parentInitializer, function()
                    return MyAltManagerDB.visibility[section.key] ~= false
                end)
                Settings.SetOnValueChangedCallback(childVarName, function(_, _, value)
                    MyAltManagerDB.visibility[child.key] = value
                    RebuildIfNeeded()
                end)
            end
        end
    end

    Settings.RegisterAddOnCategory(category)
end

function SlashCmdList.ALTMANAGER(cmd, editbox)
    local rqst, arg = strsplit(" ", cmd)

    if rqst == "help" then
        print("MyAltManager help:")
        print("   \"/alts\" to open the UI.")
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
    local main_frame = CreateFrame("frame", "AltManagerFrame", UIParent)
    AltManager.main_frame = main_frame

    main_frame:SetFrameStrata("HIGH")
    main_frame.background = main_frame:CreateTexture(nil, "BACKGROUND")
    main_frame.background:SetAllPoints()
    main_frame.background:SetDrawLayer("ARTWORK", 1)
    main_frame.background:SetColorTexture(0, 0, 0, 0.7)

    main_frame:ClearAllPoints()
    main_frame:SetPoint("CENTER", UIParent, "CENTER", xoffset, yoffset)

    main_frame:RegisterEvent("ADDON_LOADED")
    main_frame:RegisterEvent("PLAYER_LOGIN")
    main_frame:RegisterEvent("QUEST_TURNED_IN")
    main_frame:RegisterEvent("BAG_UPDATE_DELAYED")
    main_frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    main_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    main_frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    main_frame:RegisterEvent("CHALLENGE_MODE_RESET")

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

        if event == "BAG_UPDATE_DELAYED"
            or event == "QUEST_TURNED_IN"
            or event == "CURRENCY_DISPLAY_UPDATE" then
            AltManager:ScheduleCollect(event)
            return
        end

        if event == "CHALLENGE_MODE_COMPLETED"
            or event == "CHALLENGE_MODE_RESET" then
            AltManager:RequestMythicPlusMetadata()
            AltManager:ScheduleCollect(event)
            return
        end

        if event == "PLAYER_REGEN_ENABLED" then
            AltManager:ScheduleCollect(event)
            return
        end
    end)

    main_frame:EnableKeyboard(true)
    main_frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            main_frame:SetPropagateKeyboardInput(false)
        else
            main_frame:SetPropagateKeyboardInput(true)
        end
    end)
    main_frame:SetScript("OnKeyUp", function(self, key)
        if key == "ESCAPE" then
            AltManager:HideInterface()
        end
    end)

    main_frame:Hide()
end

-- ------------------------------------------------------------
-- DB and sizing
-- ------------------------------------------------------------

function AltManager:InitDB()
    local t = {}
    t.alts = 0
    t.data = {}
    t.config = { MIN_ITEM_LEVEL = 0, MIN_LEVEL = 80, show_icons = true }
    t.meta = {}
    t.visibility = {}
    return t
end

function AltManager:IsRowVisible(key)
    local vis = MyAltManagerDB and MyAltManagerDB.visibility
    if not vis then return true end

    -- Check if this key belongs to a section
    local section_key = constants.section_lookup[key]
    if section_key then
        -- If the parent section is toggled off, hide the row
        if vis[section_key] == false then return false end
        -- If this key also has an individual child toggle, check it
        if constants.child_lookup[key] and vis[key] == false then return false end
        return true
    end

    return true
end

function AltManager:CalculateYSize()
    if self.columns_table then
        local count = 0
        for key, row in pairs(self.columns_table) do
            if self:IsRowVisible(key) then
                count = count + 1
                if row.topSpacing then
                    count = count + 1
                end
            end
        end
        return (count * font_height) + 15
    end
    return sizey
end

function AltManager:CalculateXSizeNoGuidCheck()
    local alts = MyAltManagerDB.alts
    return max((alts + 1) * per_alt_x, min_x_size)
end

function AltManager:CalculateXSize()
    return self:CalculateXSizeNoGuidCheck()
end

function AltManager:OnLogin()
    self:ValidateReset()
    self:RequestMythicPlusMetadata()
    self:StoreData(self:CollectData())
    self._lastCollectAt = GetMonotonicTime()

    AltManager:CreateContent()

    self.main_frame:SetSize(self:CalculateXSize(), self:CalculateYSize())
    self.main_frame.background:SetAllPoints()

    AltManager:MakeTopBottomTextures(self.main_frame)
    AltManager:MakeBorder(self.main_frame, 5)
end

function AltManager:PurgeOldVersions()
    if MyAltManagerDB == nil or MyAltManagerDB.data == nil then return end
    local remove = {}

    for alt_guid, alt_data in spairs(MyAltManagerDB.data, function(t, a, b) return (t[a].ilevel or 0) > (t[b].ilevel or 0) end) do
        if alt_data.version == nil or alt_data.version < constants.VERSION then
            table.insert(remove, alt_guid)
        end
    end

    for _, guid in pairs(remove) do
        MyAltManagerDB.alts = MyAltManagerDB.alts - 1
        MyAltManagerDB.data[guid] = nil
    end
end

function AltManager:OnLoad()
    self.main_frame:UnregisterEvent("ADDON_LOADED")

    MyAltManagerDB = MyAltManagerDB or self:InitDB()

    -- One-time per-expansion migration (pre-expansion cleanup wipe)
    if self:RunExpansionMigrationIfNeeded() then
        self:LoadConfigFromDB()
        self:RegisterSettings()
        self.addon_loaded = true
        return
    end

    self:LoadConfigFromDB()
    self:PurgeOldVersions()

    if MyAltManagerDB.alts ~= true_numel(MyAltManagerDB.data) then
        MyAltManagerDB.alts = true_numel(MyAltManagerDB.data)
    end

    self:RegisterSettings()
    self.addon_loaded = true

    -- Request M+ metadata at load-time, not in CollectData.
    self:RequestMythicPlusMetadata()
end

-- ------------------------------------------------------------
-- UI helpers
-- ------------------------------------------------------------

function AltManager:CreateFontFrame(parent, x_size, height, relative_to, y_offset, label, justify)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(x_size, height)
    f:SetNormalFontObject(GameFontHighlightMedium)
    f:SetText(label or " ")
    f:SetPoint("TOPLEFT", relative_to, "TOPLEFT", 0, y_offset)
    local fs = f:GetFontString()
    if fs then
        fs:SetJustifyH(justify)
        fs:SetJustifyV("MIDDLE")
        f:SetPushedTextOffset(0, 0)
        fs:SetWidth(150)
        fs:SetHeight(14)
    end
    return f
end

function AltManager:Keyset()
    local keyset = {}
    if MyAltManagerDB and MyAltManagerDB.data then
        for k in pairs(MyAltManagerDB.data) do
            table.insert(keyset, k)
        end
    end
    return keyset
end

function AltManager:ValidateReset()
    local db = MyAltManagerDB
    if not db or not db.data then return end

    local keyset = {}
    for k in pairs(db.data) do
        table.insert(keyset, k)
    end

    for alt = 1, db.alts do
        local guid = keyset[alt]
        if guid and db.data[guid] then
            local expiry = db.data[guid].expires or 0
            local char_table = db.data[guid]
            if time() > expiry then
                char_table.dungeon = " "
                char_table.level = " "
                char_table.runHistory = nil
                char_table.highestCompletedWeeklyKeystone = " "
                char_table.completedWeeklyKeystoneRewards = nil
                char_table.weeklyDungeonRewards = "|cFFFFCD440/1|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r"
                char_table.weeklyDelveRewards = "|cFFFFCD440/1|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r"
                char_table.weeklyRaidRewards = "|cFFFFCD440/1|r | |cFFFFCD440/4|r | |cFFFFCD440/6|r"
                char_table.expires = self:GetNextWeeklyResetTime()
                char_table.weeklyMetaQuest = false
                char_table.specialAssignment = false
                char_table.stormarianAssault = false
                char_table.worldBoss = false
                char_table.nightmarishTask = false
                char_table.abundantOfferings = false
                char_table.legendsOfTheHaranir = false
                char_table.saththerilSoiree = false
                char_table.hiddenTrove = false
                char_table.weeklyCofferKeysCollected = 0
            end
        end
    end
end

function AltManager:Purge()
    MyAltManagerDB = self:InitDB()
    self:LoadConfigFromDB()
end

function AltManager:RemoveCharactersByName(name)
    local db = MyAltManagerDB
    local indices = {}

    for guid, data in pairs(db.data) do
        if db.data[guid].name == name then
            indices[#indices + 1] = guid
        end
    end

    db.alts = db.alts - #indices
    for i = 1, #indices do
        db.data[indices[i]] = nil
    end

    print("Found " .. (#indices) .. " characters by the name of " .. name)
    print("Please reload ui to update the displayed info.")
end

function AltManager:RemoveCharacterByGuid(index)
    local db = MyAltManagerDB
    if db.data[index] == nil then return end

    local delete = function()
        if db.data[index] == nil then return end
        db.alts = db.alts - 1
        db.data[index] = nil
        self.main_frame:SetSize(self:CalculateXSizeNoGuidCheck(), self:CalculateYSize())

        if self.main_frame.alt_columns ~= nil then
            local count = #self.main_frame.alt_columns
            for j = 0, count - 1 do
                if self.main_frame.alt_columns[count - j]:IsShown() then
                    self.main_frame.alt_columns[count - j]:Hide()
                    break
                end
            end

            if self.main_frame.remove_buttons ~= nil and self.main_frame.remove_buttons[index] ~= nil then
                self.main_frame.remove_buttons[index]:Hide()
            end
        end
        self:UpdateStrings()
    end

    delete()
end

function AltManager:CommaValues(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
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

    local _, i = GetAverageItemLevel()
    if not i or i == 0 then return end
    if i < minIlvl then return end

    db.data = db.data or {}
    local guid = data.guid

    local update = (db.data[guid] ~= nil)
    if not update then
        db.data[guid] = data
        db.alts = db.alts + 1
    else
        db.data[guid] = data
    end
end

function AltManager:CollectData()
    local _, i = GetAverageItemLevel()
    if not i or i == 0 then return end

    if UnitLevel("player") < constants.config.MIN_LEVEL then return end

    local name = UnitName("player")
    local _, class = UnitClass("player")
    local dungeon = nil
    local level = nil

    local guid = UnitGUID("player")

    local runHistory = C_MythicPlus.GetRunHistory(false, true) or {}

    local function checkWeeklyMetaQuestStatus()
        local inProgress = false
        local questIDs = {
            93912, 93769, 93913, 93910, 94457, 93766, 93911, 93909, 93767, 93892,
            93891, 93889, 93890
        }

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                return "|cFF00CF20Complete|r"
            elseif C_QuestLog.IsOnQuest(QUEST_ID) then
                inProgress = true
            end
        end

        if inProgress then
            return "|cFFFBD910In Progress|r"
        end

        return "|cFFFF0000Not Started|r"
    end

    local function checkSpecialAssignmentStatus()
        local questIDs = { 92848, 93244, 93013, 94391, 91390, 94795, 94743, 94865, 93438, 94390, 94866, 91700 }

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                return "|cFF00CF20Complete|r"
            end
        end

        return "|cFFFF0000Incomplete|r"
    end

    local function checkSaththerilSoireeStatus()
        local questIDs = { 90575, 90576, 90574, 90573 }
        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                return "|cFF00CF20Complete|r"
            end
        end
        return "|cFFFF0000Incomplete|r"
    end

    local function checkWorldBossStatus()
        local db2 = MyAltManagerDB and MyAltManagerDB.data
        if db2 and guid and db2[guid] and db2[guid].worldBoss == "|cFF00CF20Complete|r" then
            return "|cFF00CF20Complete|r"
        end

        local questIDs = { 92034, 92636, 92560, 92123 }
        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                return "|cFF00CF20Complete|r"
            end
        end

        return "|cFFFF0000Incomplete|r"
    end

    local function checkWeeklyCofferKeysCollected()
        local cofferKeyQuestIds = { 84736, 84737, 84738, 84739 }
        local cofferKeysObtained = 0
        for _, questID in ipairs(cofferKeyQuestIds) do
            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                cofferKeysObtained = cofferKeysObtained + 1
            end
        end
        return cofferKeysObtained .. "/4"
    end

    local function GetRollingCurrencyProgress(currencyID)
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        if not info then return "0/0" end

        local totalEarned = info.totalEarned or info.quantity
        local spent = math.max(0, totalEarned - info.quantity)
        local maxQuantity = info.maxQuantity
        if type(maxQuantity) ~= "number" or maxQuantity <= 0 then
            maxQuantity = info.quantity
        end

        local rollingMax = math.max(info.quantity, maxQuantity - spent)
        return ("%d/%d"):format(info.quantity, rollingMax)
    end

    local keystone_details = "None"
    local ownedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    if ownedKeystoneChallengeMapID and ownedKeystoneLevel then
        dungeon = ownedKeystoneChallengeMapID
        level = "+" .. ownedKeystoneLevel
        keystone_details = level .. " " .. (constants.DUNGEONS[dungeon] or tostring(dungeon))
    end

    local weeklyMetaQuest = checkWeeklyMetaQuestStatus()
    local worldBoss = checkWorldBossStatus()

    local abundantOfferings = C_QuestLog.IsQuestFlaggedCompleted(89507) and true or false
    local stormarianAssault = C_QuestLog.IsQuestFlaggedCompleted(94581) and true or false
    local legendsOfTheHaranir = C_QuestLog.IsQuestFlaggedCompleted(89268) and true or false
    local saththerilSoiree = checkSaththerilSoireeStatus()
    local hiddenTrove = C_QuestLog.IsQuestFlaggedCompleted(86371) and true or false
    local nightmarishTask = C_QuestLog.IsQuestFlaggedCompleted(94446) and true or false

    local specialAssignment = checkSpecialAssignmentStatus()
    local weeklyCofferKeysCollected = checkWeeklyCofferKeysCollected()

    local _, ilevel = GetAverageItemLevel()

    local conquestInfo = C_CurrencyInfo.GetCurrencyInfo(constants.currencies.conquest)
    local total_conquest_earned = conquestInfo and conquestInfo.totalEarned or 0
    local conquest = conquestInfo and conquestInfo.quantity or 0

    local honor = GetCurrencyAmount(constants.currencies.honor)
    local bloody_tokens = GetCurrencyAmount(constants.currencies.bloodyTokens)

    local forged_weapons = "PH"
    if total_conquest_earned > 2500 then
        forged_weapons = "|cFF00CF20Complete|r"
    else
        forged_weapons = "|cFFFFCD44" .. total_conquest_earned .. "/2500|r"
    end

    local adventurer_crests = GetRollingCurrencyProgress(constants.currencies.adventurer_crests)
    local veteran_crests = GetRollingCurrencyProgress(constants.currencies.veteran_crests)
    local champion_crests = GetRollingCurrencyProgress(constants.currencies.champion_crests)
    local hero_crests = GetRollingCurrencyProgress(constants.currencies.hero_crests)
    local hero_crests_current = GetCurrencyAmount(constants.currencies.hero_crests)
    local myth_crests = GetRollingCurrencyProgress(constants.currencies.myth_crests)
    local myth_crests_current = GetCurrencyAmount(constants.currencies.myth_crests)
    local radiantSparks = GetRollingCurrencyProgress(constants.currencies.radiantSparks)
    local undercoin = GetCurrencyAmount(constants.currencies.undercoin) or 0
    local anglerPearls = GetCurrencyAmount(constants.currencies.anglerPearls) or 0
    local voidlightMarl = GetCurrencyAmount(constants.currencies.voidlightMarl) or 0
    local restored_coffer_keys = GetCurrencyAmount(constants.currencies.restored_coffer_keys) or 0
    local cofferKeyShards = GetCurrencyAmount(constants.currencies.cofferKeyShards) or 0
    local shardOfDundun = GetCurrencyAmount(constants.currencies.shardOfDundun) or 0
    local remnantOfAnguish = GetCurrencyAmount(constants.currencies.remnantOfAnguish) or 0
    local unalloyedAbundance = GetCurrencyAmount(constants.currencies.unalloyedAbundance) or 0
    local nebulousVoidcore = GetRollingCurrencyProgress(constants.currencies.nebulousVoidcore)
    local untaintedManaCrystal = GetCurrencyAmount(constants.currencies.untaintedManaCrystal) or 0
    local fieldAccolade = GetCurrencyAmount(constants.currencies.fieldAccolade) or 0
    local luminousDust = GetCurrencyAmount(constants.currencies.luminousDust) or 0
    local brimmingArcana = GetCurrencyAmount(constants.currencies.brimmingArcana) or 0

    local catalystInfo = C_CurrencyInfo.GetCurrencyInfo(constants.currencies.catalyst)
    local catalystCharges = catalystInfo and catalystInfo.quantity or 0
    local catalystChargesMax = catalystInfo and catalystInfo.maxQuantity or 0

    local char_table = {}

    char_table.guid = guid
    char_table.name = name
    char_table.class = class
    char_table.ilevel = math.floor(ilevel)
    char_table.charLevel = UnitLevel("player")
    char_table.realmName = GetRealmName()
    char_table.dungeon = dungeon
    char_table.level = level
    char_table.keystone_details = keystone_details
    char_table.runHistory = runHistory
    char_table.highestCompletedWeeklyKeystone = self:GetHighestCompletedWeeklyKeystone()
    char_table.weeklyDungeonRewards = self:GetWeeklyDungeonRewards()
    char_table.weeklyDelveRewards = self:GetWeeklyDelvesRewards()
    char_table.weeklyRaidRewards = self:GetWeeklyRaidRewards()
    char_table.tierBonuses = self:GetTierBonuses()
    char_table.overallDungeonScore = self:GetOverallDungeonScore()
    char_table.weeklyMetaQuest = weeklyMetaQuest
    char_table.hiddenTrove = hiddenTrove
    char_table.specialAssignment = specialAssignment
    char_table.saththerilSoiree = saththerilSoiree
    char_table.abundantOfferings = abundantOfferings
    char_table.legendsOfTheHaranir = legendsOfTheHaranir
    char_table.stormarianAssault = stormarianAssault
    char_table.nightmarishTask = nightmarishTask
    char_table.worldBoss = worldBoss
    char_table.conquest = conquest
    char_table.forged_weapons = forged_weapons
    char_table.honor = honor
    char_table.bloody_tokens = bloody_tokens
    char_table.adventurer_crests = adventurer_crests
    char_table.veteran_crests = veteran_crests
    char_table.champion_crests = champion_crests
    char_table.hero_crests = hero_crests
    char_table.hero_crests_current = hero_crests_current
    char_table.myth_crests = myth_crests
    char_table.myth_crests_current = myth_crests_current
    char_table.radiantSparks = radiantSparks
    char_table.undercoin = undercoin
    char_table.anglerPearls = anglerPearls
    char_table.voidlightMarl = voidlightMarl
    char_table.restored_coffer_keys = restored_coffer_keys
    char_table.cofferKeyShards = cofferKeyShards
    char_table.shardOfDundun = shardOfDundun
    char_table.remnantOfAnguish = remnantOfAnguish
    char_table.unalloyedAbundance = unalloyedAbundance
    char_table.nebulousVoidcore = nebulousVoidcore
    char_table.untaintedManaCrystal = untaintedManaCrystal
    char_table.fieldAccolade = fieldAccolade
    char_table.luminousDust = luminousDust
    char_table.brimmingArcana = brimmingArcana
    char_table.weeklyCofferKeysCollected = weeklyCofferKeysCollected
    char_table.catalystCharges = string.format("%d/%d", catalystCharges, catalystChargesMax)
    char_table.version = constants.VERSION
    char_table.expires = self:GetNextWeeklyResetTime()
    char_table.dataObtained = time()
    char_table.timeUntilReset = C_DateAndTime.GetSecondsUntilDailyReset()

    return char_table
end

-- ------------------------------------------------------------
-- Tier, score, weekly rewards
-- ------------------------------------------------------------

function AltManager:GetTierBonuses()
    local tierText = ""
    local tierCount = 0
    local tierItems = {}

    for slotId in pairs(constants.TIER_SLOTS) do
        local invItem = GetInventoryItemID("player", slotId)
        if invItem then
            local setId = select(16, C_Item.GetItemInfo(invItem))
            if setId and constants.TIER_SETS[setId] then
                tierItems["equip:" .. slotId] = 1
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
                    tierItems[("bag:%d:%d"):format(container, slot)] = 1
                end
            end
        end
    end

    for _ in pairs(tierItems) do
        tierCount = tierCount + 1
    end

    if tierCount > 0 then
        if tierCount >= 4 then
            tierCount = 4
        end
        tierText = tierCount .. "/4 Set"
    else
        tierText = "No Set"
    end

    return tierText
end

function AltManager:GetOverallDungeonScore()
    local overallDungeonScore = C_ChallengeMode.GetOverallDungeonScore()
    local color = C_ChallengeMode.GetDungeonScoreRarityColor(overallDungeonScore)
    local r, g, b = color.r * 255, color.g * 255, color.b * 255
    local colorString = string.format("|cff%02x%02x%02x", r, g, b)
    return colorString .. overallDungeonScore .. "|r"
end

function AltManager:GetWeeklyDelvesRewards()
    local completedDelves = C_WeeklyRewards.GetActivities(6) or {}
    local delveRewards = {}

    for i = 1, 3 do
        local status = completedDelves[i] or { level = 0, progress = 0 }
        if status.level > 0 then
            delveRewards[i] = "|cFF00CF20" .. (constants.DELVE_ILVL[status.level] or "?") .. "|r"
        else
            local progress = status and status.progress or 0
            local total = (i == 1 and 2) or (i == 2 and 4) or (i == 3 and 8)
            delveRewards[i] = "|cFFFFCD44" .. progress .. "/" .. total .. "|r"
        end
    end

    return table.concat(delveRewards, " | ")
end

function AltManager:GetWeeklyRaidRewards()
    local completedRaids = C_WeeklyRewards.GetActivities(3) or {}
    local raidRewards = {}

    for i = 1, 3 do
        local status = completedRaids[i] or { level = 0, progress = 0 }
        if status.level > 0 then
            raidRewards[i] = "|cFF00CF20" .. (constants.RAID_ILVL[status.level] or "?") .. "|r"
        else
            local progress = status and status.progress or 0
            local total = (i == 1 and 2) or (i == 2 and 4) or (i == 3 and 6)
            raidRewards[i] = "|cFFFFCD44" .. progress .. "/" .. total .. "|r"
        end
    end

    return table.concat(raidRewards, " | ")
end

function AltManager:GetWeeklyDungeonRewards()
    local completedDungeons = C_WeeklyRewards.GetActivities(1) or {}
    local dungeonRewards = {}

    for i = 1, 3 do
        local status = completedDungeons[i] or nil
        if status and status.level ~= nil and status.progress ~= nil and status.threshold ~= nil and status.level >= 0 and status.progress >= status.threshold then
            local levelToUse = status.level > 10 and 10 or status.level
            dungeonRewards[i] = "|cFF00CF20" .. (constants.DUNGEON_ILVL[levelToUse] or "?") .. "|r"
        else
            local progress = status and status.progress or 0
            local total = (i == 1 and 1) or (i == 2 and 4) or (i == 3 and 8)
            dungeonRewards[i] = "|cFFFFCD44" .. progress .. "/" .. total .. "|r"
        end
    end

    return table.concat(dungeonRewards, " | ")
end

function AltManager:GetHighestCompletedWeeklyKeystone()
    local info = C_MythicPlus.GetRunHistory(false, true) or {}

    table.sort(info, function(a, b)
        return (a.level or 0) > (b.level or 0)
    end)

    local highestRun = info[1]
    local level = highestRun and highestRun.level or 0
    local dungeon = highestRun and highestRun.mapChallengeModeID or ""

    if level == 0 then
        return " "
    elseif level and level > 0 then
        local color
        if level >= 10 then
            color = "|cFFFF8000"
        elseif level >= 7 then
            color = "|cFFA335EE"
        elseif level >= 5 then
            color = "|cFF0070DD"
        elseif level >= 2 then
            color = "|cFF1EFF00"
        end
        return color .. "+" .. level .. " " .. (constants.DUNGEONS[dungeon] or tostring(dungeon)) .. "|r"
    else
        return " "
    end
end

function AltManager:GetLowestLevelInTopRuns(numRuns)
    local runHistory = C_MythicPlus.GetRunHistory(false, true) or {}
    table.sort(runHistory, function(left, right) return (left.level or 0) > (right.level or 0) end)

    local lowestLevel
    local lowestCount = 0
    for i = math.min(numRuns, #runHistory), 1, -1 do
        local run = runHistory[i]
        if not lowestLevel then
            lowestLevel = run.level
        end
        if lowestLevel == run.level then
            lowestCount = lowestCount + 1
        else
            break
        end
    end
    return lowestLevel
end

function AltManager:GetSortedColumnKeys()
    if self._sortedColumnKeys then
        return self._sortedColumnKeys
    end

    local keys = {}
    for key in pairs(self.columns_table or {}) do
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b)
        return self.columns_table[a].order < self.columns_table[b].order
    end)

    self._sortedColumnKeys = keys
    return keys
end

-- ------------------------------------------------------------
-- UI content
-- ------------------------------------------------------------

function AltManager:CreateContent()
    self.main_frame.closeButton = CreateFrame("Button", "CloseButton", self.main_frame, "UIPanelCloseButton")
    self.main_frame.closeButton:ClearAllPoints()
    self.main_frame.closeButton:SetPoint("BOTTOMRIGHT", self.main_frame, "TOPRIGHT", -3, 2)
    self.main_frame.closeButton:SetScript("OnClick", function() AltManager:HideInterface() end)

    local column_table = {
        name = {
            order = 1,
            topSpacing = true,
            label = constants.labels.NAME,
            data = function(alt_data) return alt_data.name .. " (" .. (alt_data.ilevel or 0) .. ")" end,
            color = function(alt_data) return RAID_CLASS_COLORS[alt_data.class] end,
        },
        realm = {
            order = 2,
            data = function(alt_data) return tostring(alt_data.realmName) .. "  " end,
            remove_button = function(alt_data) return self:CreateRemoveButton(function() AltManager:RemoveCharacterByGuid(alt_data.guid) end) end,
        },
        tier = {
            order = 3,
            label = constants.labels.TIER_SET,
            data = function(alt_data) return (tostring(alt_data.tierBonuses) or "No Set") end,
        },
        catalyst_charges = {
            order = 4,
            label = constants.labels.CATALYST_CHARGES,
            data = function(alt_data) return (alt_data.catalystCharges and tostring(alt_data.catalystCharges) or "0/0") end,
        },
        nebulousVoidcore = {
            order = 4.5,
            label = constants.labels.NEBULOUS_VOIDCORE,
            data = function(alt_data) return (alt_data.nebulousVoidcore and tostring(alt_data.nebulousVoidcore) or "0/0") end,
        },
        mythic_title = {
            order = 5,
            topSpacing = true,
            label = constants.labels.KEYSTONE,
            title = true,
            data = function(_) return " " end,
        },
        mythic_rating = {
            order = 6,
            label = constants.labels.MYTHIC_RATING,
            data = function(alt_data) return tostring(alt_data.overallDungeonScore) or 0 end,
        },
        current_keystone = {
            order = 7,
            label = constants.labels.CURRENT_KEYSTONE,
            data = function(alt_data) return tostring(alt_data.keystone_details) or "None" end,
        },
        weekly_highest = {
            order = 8,
            label = constants.labels.WEEKLY_HIGHEST,
            data = function(alt_data) return tostring(alt_data.highestCompletedWeeklyKeystone) or " " end,
        },
        great_vault_rewards = {
            order = 9,
            topSpacing = true,
            label = constants.labels.GREAT_VAULT_REWARDS,
            title = true,
            data = function(_) return " " end,
        },
        weekly_raid_rewards = {
            order = 10,
            label = constants.labels.WEEKLY_RAID_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyRaidRewards) or "|cFFFFCD440/2|r | |cFFFFCD440/4|r | |cFFFFCD440/6|r" end,
        },
        weekly_key_rewards = {
            order = 11,
            label = constants.labels.WEEKLY_DUNGEON_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyDungeonRewards) or "|cFFFFCD440/1|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r" end,
        },
        weekly_delve_rewards = {
            order = 12,
            label = constants.labels.WEEKLY_DELVE_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyDelveRewards) or "|cFFFFCD440/2|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r" end,
        },
        pvp_data = {
            order = 13,
            topSpacing = true,
            label = constants.labels.PVP,
            title = true,
            data = function(_) return " " end,
        },
        pvp_honor = {
            order = 14,
            label = constants.labels.HONOR,
            data = function(alt_data) return (alt_data.honor and tostring(alt_data.honor) or "0") end,
        },
        pvp_conquest = {
            order = 15,
            label = constants.labels.CONQUEST,
            data = function(alt_data) return (alt_data.conquest and tostring(alt_data.conquest) or "0") end,
        },
        pvp_conquest_earned = {
            order = 16,
            label = constants.labels.FORGED_WEAPONS,
            data = function(alt_data) return (alt_data.forged_weapons and tostring(alt_data.forged_weapons) or "|cFFFF0000Incomplete|r") end,
        },
        pvp_bloody_tokens = {
            order = 17,
            label = constants.labels.BLOODY_TOKENS,
            data = function(alt_data) return (alt_data.bloody_tokens and tostring(alt_data.bloody_tokens) or "0") end,
        },
        weekly_quests = {
            order = 18,
            topSpacing = true,
            label = constants.labels.WEEKLY_QUESTS,
            title = true,
            data = function(_) return " " end,
        },
        weekly_meta_quest = {
            order = 19,
            label = constants.labels.WEEKLY_META_QUEST,
            data = function(alt_data) return (alt_data.weeklyMetaQuest and tostring(alt_data.weeklyMetaQuest) or "|cFFFF0000Not Started|r") end,
        },
        special_assignment = {
            order = 20,
            label = constants.labels.SPECIAL_ASSIGNMENT,
            data = function(alt_data) return (alt_data.specialAssignment and tostring(alt_data.specialAssignment) or "|cFFFF0000Incomplete|r") end,
        },
        saththeril_soiree = {
            order = 21,
            label = constants.labels.SATHTHERIL_SOIREE,
            data = function(alt_data) return (alt_data.saththerilSoiree and tostring(alt_data.saththerilSoiree) or "|cFFFF0000Incomplete|r") end,
        },
        abundant_offerings = {
            order = 22,
            label = constants.labels.ABUNDANT_OFFERINGS,
            data = function(alt_data) return alt_data.abundantOfferings and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        legends_of_the_haranir = {
            order = 23,
            label = constants.labels.LEGENDS_OF_THE_HARANIR,
            data = function(alt_data) return alt_data.legendsOfTheHaranir and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        stormarian_assault = {
            order = 24,
            label = constants.labels.STORMARIAN_ASSAULT,
            data = function(alt_data) return alt_data.stormarianAssault and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        hidden_trove = {
            order = 25,
            label = constants.labels.HIDDEN_TROVE,
            data = function(alt_data) return alt_data.hiddenTrove and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        nightmarish_task = {
            order = 25.5,
            label = constants.labels.NIGHTMARISH_TASK,
            data = function(alt_data) return alt_data.nightmarishTask and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        world_boss = {
            order = 26,
            label = constants.labels.WORLD_BOSS,
            data = function(alt_data) return (alt_data.worldBoss and tostring(alt_data.worldBoss) or "|cFFFF0000Incomplete|r") end,
        },
        currencies = {
            order = 27,
            topSpacing = true,
            label = constants.labels.CURRENCIES,
            title = true,
            data = function(_) return " " end,
        },
        radiantSparks = {
            order = 28,
            label = constants.labels.RADIANT_SPARKS,
            data = function(alt_data) return (alt_data.radiantSparks and tostring(alt_data.radiantSparks) or "0") end,
        },
        adventurer_crests = {
            order = 29,
            label = constants.labels.ADVENTURER_CRESTS,
            data = function(alt_data) return (alt_data.adventurer_crests and tostring(alt_data.adventurer_crests) or "0") end,
        },
        veteran_crests = {
            order = 30,
            label = constants.labels.VETERAN_CRESTS,
            data = function(alt_data) return (alt_data.veteran_crests and tostring(alt_data.veteran_crests) or "0") end,
        },
        champion_crests = {
            order = 31,
            label = constants.labels.CHAMPION_CRESTS,
            data = function(alt_data) return (alt_data.champion_crests and tostring(alt_data.champion_crests) or "0") end,
        },
        hero_crests = {
            order = 32,
            label = constants.labels.HERO_CRESTS,
            data = function(alt_data) return (alt_data.hero_crests and tostring(alt_data.hero_crests) or "0") end,
        },
        myth_crests = {
            order = 33,
            label = constants.labels.MYTH_CRESTS,
            data = function(alt_data) return (alt_data.myth_crests and tostring(alt_data.myth_crests) or "0") end,
        },
        restored_coffer_keys = {
            order = 34,
            label = constants.labels.RESTORED_COFFER_KEY,
            data = function(alt_data) return (alt_data.restored_coffer_keys and tostring(alt_data.restored_coffer_keys) or "0") end,
        },
        coffer_key_shards = {
            order = 35,
            label = constants.labels.COFFER_KEY_SHARDS,
            data = function(alt_data) return (alt_data.cofferKeyShards and tostring(alt_data.cofferKeyShards) or "0") end,
        },
        undercoin = {
            order = 36,
            label = constants.labels.UNDERCOIN,
            data = function(alt_data) return (alt_data.undercoin and tostring(alt_data.undercoin) or "0") end,
        },
        anglerPearls = {
            order = 36.5,
            label = constants.labels.ANGLER_PEARLS,
            data = function(alt_data) return (alt_data.anglerPearls and tostring(alt_data.anglerPearls) or "0") end,
        },
        voidlightMarl = {
            order = 37,
            label = constants.labels.VOIDLIGHT_MARL,
            data = function(alt_data) return (alt_data.voidlightMarl and tostring(alt_data.voidlightMarl) or "0") end,
        },
        shardOfDundun = {
            order = 38,
            label = constants.labels.SHARD_OF_DUNDUN,
            data = function(alt_data) return (alt_data.shardOfDundun and tostring(alt_data.shardOfDundun) or "0") end,
        },
        remnantOfAnguish = {
            order = 39,
            label = constants.labels.REMNANT_OF_ANGUISH,
            data = function(alt_data) return (alt_data.remnantOfAnguish and tostring(alt_data.remnantOfAnguish) or "0") end,
        },
        unalloyedAbundance = {
            order = 40,
            label = constants.labels.UNALLOYED_ABUNDANCE,
            data = function(alt_data) return (alt_data.unalloyedAbundance and tostring(alt_data.unalloyedAbundance) or "0") end,
        },
        untaintedManaCrystal = {
            order = 42,
            label = constants.labels.UNTAINTED_MANA_CRYSTAL,
            data = function(alt_data) return (alt_data.untaintedManaCrystal and tostring(alt_data.untaintedManaCrystal) or "0") end,
        },
        fieldAccolade = {
            order = 43,
            label = constants.labels.FIELD_ACCOLADE,
            data = function(alt_data) return (alt_data.fieldAccolade and tostring(alt_data.fieldAccolade) or "0") end,
        },
        luminousDust = {
            order = 44,
            label = constants.labels.LUMINOUS_DUST,
            data = function(alt_data) return (alt_data.luminousDust and tostring(alt_data.luminousDust) or "0") end,
        },
        brimmingArcana = {
            order = 45,
            label = constants.labels.BRIMMING_ARCANA,
            data = function(alt_data) return (alt_data.brimmingArcana and tostring(alt_data.brimmingArcana) or "0") end,
        },
    }

    self.columns_table = column_table
    self._sortedColumnKeys = nil

    local calcY = self:CalculateYSize()
    local label_column = self.main_frame.label_column or CreateFrame("Button", nil, self.main_frame)
    if not self.main_frame.label_column then self.main_frame.label_column = label_column end
    label_column:SetSize(per_alt_x, calcY)
    label_column:SetPoint("TOPLEFT", self.main_frame, "TOPLEFT", 4, -1)

    self.main_frame.label_frames = self.main_frame.label_frames or {}

    local show_icons = MyAltManagerDB and MyAltManagerDB.config and MyAltManagerDB.config.show_icons
    if show_icons == nil then show_icons = true end

    local i = 1
    for _, key in ipairs(self:GetSortedColumnKeys()) do
        local row = self.columns_table[key]
        if self:IsRowVisible(key) then
            if row.topSpacing then
                i = i + 1
            end
            if row.label then
                local display_label = row.label
                if display_label ~= "" and not row.title then
                    display_label = display_label .. ":"
                elseif display_label == "" then
                    display_label = " "
                end
                if not show_icons then
                    display_label = StripInlineIconMarkup(display_label)
                end
                local frame = self:CreateFontFrame(self.main_frame, per_alt_x, font_height, label_column, -(i - 1) * font_height, display_label, "RIGHT")
                table.insert(self.main_frame.label_frames, frame)
                self.main_frame.lowest_point = -(i - 1) * font_height
            end
            i = i + 1
        end
    end
end

function AltManager:UpdateStrings()
    local font_height = 14
    local db = MyAltManagerDB

    self.main_frame.alt_columns = self.main_frame.alt_columns or {}

    local alt = 0
    for alt_guid, alt_data in spairs(db.data, function(t, a, b) return (t[a].ilevel or 0) > (t[b].ilevel or 0) end) do
        alt = alt + 1
        local anchor_frame = self.main_frame.alt_columns[alt] or CreateFrame("Button", nil, self.main_frame)
        if not self.main_frame.alt_columns[alt] then
            self.main_frame.alt_columns[alt] = anchor_frame
            self.main_frame.alt_columns[alt].guid = alt_guid
            anchor_frame:SetPoint("TOPLEFT", self.main_frame, "TOPLEFT", per_alt_x * alt, -1)
        end

        anchor_frame:SetSize(per_alt_x, self:CalculateYSize())
        self.main_frame.alt_columns[alt].label_columns = self.main_frame.alt_columns[alt].label_columns or {}
        local label_columns = self.main_frame.alt_columns[alt].label_columns

        local i = 1
        for _, key in ipairs(self:GetSortedColumnKeys()) do
            local column = self.columns_table[key]
            if self:IsRowVisible(key) then
                if column.topSpacing then
                    i = i + 1
                end
                if type(column.data) == "function" then
                    local cellText = column.data(alt_data)
                    local current_row = label_columns[i] or self:CreateFontFrame(anchor_frame, per_alt_x, column.font_height or font_height, anchor_frame, -(i - 1) * font_height, cellText, "CENTER")
                    if not self.main_frame.alt_columns[alt].label_columns[i] then
                        self.main_frame.alt_columns[alt].label_columns[i] = current_row
                    end

                    if column.color then
                        local color = column.color(alt_data)
                        current_row:GetFontString():SetTextColor(color.r, color.g, color.b, 1)
                    end

                    current_row:SetText(cellText)

                    if column.font then
                        current_row:GetFontString():SetFont(column.font, ilvl_text_size)
                    end

                    if column.justify then
                        current_row:GetFontString():SetJustifyV(column.justify)
                    end

                    if column.remove_button ~= nil then
                        self.main_frame.remove_buttons = self.main_frame.remove_buttons or {}
                        local extra = self.main_frame.remove_buttons[alt_data.guid] or column.remove_button(alt_data)
                        if self.main_frame.remove_buttons[alt_data.guid] == nil then
                            self.main_frame.remove_buttons[alt_data.guid] = extra
                        end
                        extra:SetParent(current_row)
                        extra:SetPoint("TOPRIGHT", current_row, "TOPRIGHT", -20, 0)
                        extra:SetPoint("BOTTOMRIGHT", current_row, "TOPRIGHT", -18, -remove_button_size + 4)
                        extra:SetFrameLevel(current_row:GetFrameLevel() + 1)
                        extra:Show()
                    end
                end
                i = i + 1
            end
        end
    end
end

function AltManager:RebuildUI()
    if not self.main_frame then return end

    -- Hide old label frames
    if self.main_frame.label_frames then
        for _, frame in ipairs(self.main_frame.label_frames) do
            frame:Hide()
        end
        self.main_frame.label_frames = nil
    end

    -- Hide old label column
    if self.main_frame.label_column then
        self.main_frame.label_column:Hide()
        self.main_frame.label_column = nil
    end

    -- Hide old alt data columns
    if self.main_frame.alt_columns then
        for _, col in pairs(self.main_frame.alt_columns) do
            col:Hide()
        end
        self.main_frame.alt_columns = nil
    end

    -- Hide old remove buttons
    if self.main_frame.remove_buttons then
        for _, btn in pairs(self.main_frame.remove_buttons) do
            btn:Hide()
        end
        self.main_frame.remove_buttons = nil
    end

    self:CreateContent()
    self.main_frame:SetSize(self:CalculateXSize(), self:CalculateYSize())
    self.main_frame.background:SetAllPoints()
    self:MakeTopBottomTextures(self.main_frame)
    self:MakeBorder(self.main_frame, 5)

    if MyAltManagerDB and MyAltManagerDB.data then
        self:UpdateStrings()
    end
end

function AltManager:HideInterface()
    self.main_frame:Hide()
end

function AltManager:ShowInterface()
    self.main_frame:Show()
    if self:CanCollectNow() then
        self:StoreData(self:CollectData())
    end
    self.main_frame:SetSize(self:CalculateXSize(), self:CalculateYSize())
    self.main_frame.background:SetAllPoints()
    self:MakeTopBottomTextures(self.main_frame)
    self:MakeBorder(self.main_frame, 5)
    self:UpdateStrings()
end

function AltManager:CreateRemoveButton(func)
    local frame = CreateFrame("Button", nil, nil)
    frame:ClearAllPoints()
    frame:SetScript("OnClick", function() func() end)
    self:MakeRemoveTexture(frame)
    frame:SetWidth(remove_button_size)
    return frame
end

function AltManager:MakeRemoveTexture(frame)
    if frame.remove_tex == nil then
        frame.remove_tex = frame:CreateTexture(nil, "BACKGROUND")
        frame.remove_tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
        frame.remove_tex:SetAllPoints()
        frame.remove_tex:Show()
    end
    return frame
end

function AltManager:MakeTopBottomTextures(frame)
    if frame.bottomPanel == nil then
        frame.bottomPanel = frame:CreateTexture(nil)
    end
    if frame.topPanel == nil then
        frame.topPanel = CreateFrame("Frame", "AltManagerTopPanel", frame)
        frame.topPanelTex = frame.topPanel:CreateTexture(nil, "BACKGROUND")
        frame.topPanelTex:SetAllPoints()
        frame.topPanelTex:SetDrawLayer("ARTWORK", -5)
        frame.topPanelTex:SetColorTexture(0, 0, 0, 1)

        frame.topPanelString = frame.topPanel:CreateFontString("AddonName")
        frame.topPanelString:SetFont("Fonts\\FRIZQT__.TTF", 16)
        frame.topPanelString:SetTextColor(1, 1, 1, 1)
        frame.topPanelString:SetJustifyH("CENTER")
        frame.topPanelString:SetJustifyV("MIDDLE")
        frame.topPanelString:SetWidth(260)
        frame.topPanelString:SetHeight(20)
        frame.topPanelString:SetText("My Alt Manager")
        frame.topPanelString:ClearAllPoints()
        frame.topPanelString:SetPoint("CENTER", frame.topPanel, "CENTER", 0, 0)
        frame.topPanelString:Show()
    end

    frame.bottomPanel:SetColorTexture(0, 0, 0, 1)
    frame.bottomPanel:ClearAllPoints()
    frame.bottomPanel:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
    frame.bottomPanel:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.bottomPanel:SetSize(frame:GetWidth(), 30)
    frame.bottomPanel:SetDrawLayer("ARTWORK", 7)

    if frame.bottomPanelString == nil then
        frame.bottomPanelString = frame:CreateFontString(nil, "OVERLAY")
        frame.bottomPanelString:SetFont("Fonts\\FRIZQT__.TTF", 12)
        frame.bottomPanelString:SetTextColor(1, 1, 1, 1)
        frame.bottomPanelString:SetJustifyH("CENTER")
        frame.bottomPanelString:SetJustifyV("MIDDLE")
        frame.bottomPanelString:SetWidth(260)
        frame.bottomPanelString:SetHeight(20)
        frame.bottomPanelString:SetText("Version " .. constants.VERSION)
        frame.bottomPanelString:ClearAllPoints()
        frame.bottomPanelString:SetPoint("CENTER", frame.bottomPanel, "CENTER", 0, 0)
        frame.bottomPanelString:Show()
    end

    frame.topPanel:ClearAllPoints()
    frame.topPanel:SetSize(frame:GetWidth(), 30)
    frame.topPanel:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
    frame.topPanel:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0)

    -- Keep existing drag behavior unless you want it locked.
    frame:SetMovable(true)
    frame.topPanel:EnableMouse(true)
    frame.topPanel:RegisterForDrag("LeftButton")
    frame.topPanel:SetScript("OnDragStart", function()
        frame:SetMovable(true)
        frame:StartMoving()
    end)
    frame.topPanel:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        frame:SetMovable(false)
    end)
end

function AltManager:MakeBorderPart(frame, x, y, xoff, yoff, part)
    if part == nil then
        part = frame:CreateTexture(nil)
    end
    part:SetTexture(0, 0, 0, 1)
    part:ClearAllPoints()
    part:SetPoint("TOPLEFT", frame, "TOPLEFT", xoff, yoff)
    part:SetSize(x, y)
    part:SetDrawLayer("ARTWORK", 7)
    return part
end

function AltManager:MakeBorder(frame, size)
    if size == 0 then
        return
    end
    frame.borderTop = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, 0, frame.borderTop)
    frame.borderLeft = self:MakeBorderPart(frame, size, frame:GetHeight(), 0, 0, frame.borderLeft)
    frame.borderBottom = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, -frame:GetHeight() + size, frame.borderBottom)
    frame.borderRight = self:MakeBorderPart(frame, size, frame:GetHeight(), frame:GetWidth() - size, 0, frame.borderRight)
end

-- ------------------------------------------------------------
-- Reset time helpers (unchanged)
-- ------------------------------------------------------------

function AltManager:GetNextWeeklyResetTime()
    local seconds = C_DateAndTime.GetSecondsUntilWeeklyReset()
    if not seconds or seconds <= 0 then return nil end
    return time() + seconds
end

function AltManager:GetNextDailyResetTime()
    local seconds = C_DateAndTime.GetSecondsUntilDailyReset()
    if not seconds or seconds <= 0 then return nil end
    return time() + seconds
end

function AltManager:TimeString(length)
    if length == 0 then
        return "Now"
    end
    if length < 3600 then
        return string.format("%d mins", length / 60)
    end
    if length < 86400 then
        return string.format("%d hrs %d mins", length / 3600, (length % 3600) / 60)
    end
    return string.format("%d days %d hrs", length / 86400, (length % 86400) / 3600)
end
