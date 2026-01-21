local _, AltManager = ...

_G["AltManager"] = AltManager

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 2020-10-14
-- updates for Dragonflight, and The War Within by: Faith - Frostmourne, 2021-2024
-- Last edit: 2023-11-12
-- updates for Midnight pre-patch 12.0 by: Faith - Frostmourne, 2026-01-21

local sizey = 535
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
constants.config.MIN_ITEM_LEVEL = 0 -- controlled via /alts min <ilevel>, default 0

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
    WEEKLY_DELVE_REWARDS = "Weekly Delves",
    TIER_SET = "Tier 34",
    CATALYST_CHARGES = "Catalyst Charges",
    CURRENCIES = "Currencies",
    CONQUEST = "Conquest |TInterface\\Icons\\achievement_legionpvp2tier3:12:12:0:0|t",
    FORGED_WEAPONS = "Forged Weapons |TInterface\\Icons\\inv_misc_token_pvp02:12:12:0:0|t",
    HONOR = "Honor |TInterface\\Icons\\achievement_legionpvptier4:12:12:0:0|t",
    BLOODY_TOKENS = "Bloody Tokens |TInterface\\Icons\\inv_10_dungeonjewelry_titan_trinket_2_color2:12:12:0:0|t",
    LFR_CRESTS = "Weathered |TInterface\\Icons\\inv_crestupgrade_ethereal_weathered:12:12:0:0|t",
    NORMAL_CRESTS = "Carved |TInterface\\Icons\\inv_crestupgrade_ethereal_carved:12:12:0:0|t",
    HEROIC_CRESTS = "Runed |TInterface\\Icons\\inv_crestupgrade_ethereal_runed:12:12:0:0|t",
    MYTHIC_CRESTS = "Gilded |TInterface\\Icons\\inv_crestupgrade_ethereal_gilded_enchanted:12:12:0:0|t",
    VALORSTONES = "Valorstones |TInterface\\Icons\\inv_valorstone_base:12:12:0:0|t",
    FLAME_BLESSED_IRON = "Flame-Blessed |TInterface\\Icons\\inv_siren_isle_flameblessed_iron:12:12:0:0|t",
    UNDERCOIN = "Undercoin |TInterface\\Icons\\inv_misc_elvencoins:12:12:0:0|t",
    STARLIGHT_SPARKS = "Starlight Sparks |TInterface\\Icons\\inv_10_enchanting_dust_color4:12:12:0:0|t",
    HIDDEN_TROVE = "Hidden Trove (Delves)",
    RESTORED_COFFER_KEY = "Bountiful Keys |TInterface\\Icons\\inv_10_blacksmithing_consumable_key_color1:12:12:0:0|t",
    RESONANCE_CRYSTALS = "Resonance Crystals",
    KHAZ_ALGAR_EMISSARY = "Khaz Algar Emissary",
    PHASE_DIVING = "Phase Diving",
    ECOLOGICAL_SUCCESSION = "Ecological Succession",
    URGE_TO_SURGE = "Urge to Surge",
    SPREADING_THE_LIGHT = "Spreading the Light",
    SPECIAL_ASSIGNMENT = "Special Assignment",
    AZJ_KAHET_PACT = "Azj-Kahet Pacts",
    EARTHEN_THEATER = "Earthen Theater",
    COLLECTING_WAX = "Collecting Wax",
    AWAKENING_THE_MACHINE = "Awakening the Machine",
    GREAT_VAULT_REWARDS = "Great Vault",
    WORLD_BOSS = "World Boss",
    PVP = "PVP",
    UNTAINTED_MANA_CRYSTALS = "Untainted Mana |TInterface\\Icons\\inv_elemental_primal_mana:12:12:0:0|t",
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

    -- New dungeons (Midnight / 12.0)
    [556] = "Saron",      -- Pit of Saron
    [557] = "Windrunner", -- Windrunner Spire
    [558] = "Magisters",  -- Magisters' Terrace
    [559] = "Xenas",      -- Nexus-Point Xenas
    [560] = "Maisara",    -- Maisara Caverns
}

constants.RAID_ILVL = {
    [1] = "D:N",
    [2] = "D:H",
    [3] = "R:10N",
    [4] = "R:25N",
    [5] = "R:10H",
    [6] = "R:25H",
    [7] = "671", -- LFR
    [8] = "D:CM",
    [9] = "R:40",
    [14] = "684", -- Normal
    [15] = "697", -- Heroic
    [16] = "710", -- Mythic
    [17] = "671", -- LFR
    [23] = "D:M",
    [24] = "D:TW",
    [33] = "R:TW",
    [202] = "Story",
}

-- Delves derived from new Dungeon +8 (269) and Dungeon +2 (259)
constants.DELVE_ILVL = {
    [1]  = "230", -- 269 - 39
    [2]  = "243", -- 269 - 26
    [3]  = "246", -- 269 - 23
    [4]  = "256", -- 269 - 13
    [5]  = "263", -- 269 - 6
    [6]  = "266", -- 269 - 3
    [7]  = "266", -- 269 - 3
    [8]  = "259", -- same as Dungeon +2
    [9]  = "259",
    [10] = "259",
    [11] = "259",
}

-- Great Vault rewards (Keystones)
constants.DUNGEON_ILVL = {
    [0]  = "246",
    [1]  = "259",
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
    conquest = "1602",
    honor = "1792",
    bloodyTokens = "2123",
    catalyst = "3269",
    valorstones = "3008",
    undercoin = "2803",
    resonance_crystals = "2815",
    restored_coffer_keys = "3028",
    lfr_crests = "3284",
    normal_crests = "3286",
    heroic_crests = "3288",
    mythic_crests = "3290",
    flameBlessedIron = "3090",
    starlightSparks = "3141",
    untaintedManaCrystals = "3356",
}

constants.TIER_SETS = {
    -- Existing
    [1919] = true,
    [1920] = true,
    [1921] = true,
    [1922] = true,
    [1923] = true,
    [1924] = true,
    [1925] = true,
    [1926] = true,
    [1927] = true,
    [1928] = true,
    [1929] = true,
    [1930] = true,
    [1931] = true,

    -- New (Midnight / 12.0)
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

constants.VERSION = "12.0.0.1"

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

    self._collectTimer = C_Timer.After(0.5, function()
        self._collectTimer = nil
        if not AltManager:CanCollectNow() then return end
        local data = AltManager:CollectData(false)
        AltManager:StoreData(data)
    end)
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

    if db.config.MIN_ITEM_LEVEL == nil then
        db.config.MIN_ITEM_LEVEL = 0
    end

    constants.config.MIN_ITEM_LEVEL = tonumber(db.config.MIN_ITEM_LEVEL) or 0
end

function SlashCmdList.ALTMANAGER(cmd, editbox)
    local rqst, arg = strsplit(" ", cmd)

    if rqst == "help" then
        print("MyAltManager help:")
        print("   \"/alts\" to open the UI.")
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
    main_frame:RegisterEvent("PLAYER_LOGOUT")
    main_frame:RegisterEvent("QUEST_TURNED_IN")
    main_frame:RegisterEvent("BAG_UPDATE_DELAYED")
    main_frame:RegisterEvent("ARTIFACT_XP_UPDATE")
    main_frame:RegisterEvent("CHAT_MSG_CURRENCY")
    main_frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    main_frame:RegisterEvent("PLAYER_LEAVING_WORLD")

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
            AltManager:ScheduleCollect("login")
            LeaveChannelByName("Services")
            return
        end

        if event == "PLAYER_LEAVING_WORLD" then
            AltManager:ScheduleCollect("leaving_world")
            return
        end

        if event == "BAG_UPDATE_DELAYED"
            or event == "QUEST_TURNED_IN"
            or event == "CHAT_MSG_CURRENCY"
            or event == "CURRENCY_DISPLAY_UPDATE" then
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
    t.config = { MIN_ITEM_LEVEL = 0 }
    t.meta = {}
    return t
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
    self:StoreData(self:CollectData())

    self.main_frame:SetSize(self:CalculateXSize(), sizey)
    self.main_frame.background:SetAllPoints()

    AltManager:CreateContent()
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
        self.addon_loaded = true
        return
    end

    self:LoadConfigFromDB()
    self:PurgeOldVersions()

    if MyAltManagerDB.alts ~= true_numel(MyAltManagerDB.data) then
        MyAltManagerDB.alts = true_numel(MyAltManagerDB.data)
    end

    self.addon_loaded = true

    -- Requests are safe; still keep them off combat-heavy loops.
    C_MythicPlus.RequestRewards()
    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    for k in pairs(constants.DUNGEONS) do
        C_MythicPlus.RequestMapInfo(k)
    end
end

-- ------------------------------------------------------------
-- UI helpers
-- ------------------------------------------------------------

function AltManager:CreateFontFrame(parent, x_size, height, relative_to, y_offset, label, justify)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(x_size, height)
    f:SetNormalFontObject(GameFontHighlightMedium)
    f:SetText(label)
    f:SetPoint("TOPLEFT", relative_to, "TOPLEFT", 0, y_offset)
    f:GetFontString():SetJustifyH(justify)
    f:GetFontString():SetJustifyV("MIDDLE")
    f:SetPushedTextOffset(0, 0)
    f:GetFontString():SetWidth(150)
    f:GetFontString():SetHeight(14)
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
                char_table.khazAlgarEmissary = false
                char_table.azjKahetPacts = false
                char_table.spreadingTheLight = false
                char_table.specialAssignment = false
                char_table.collectingWax = false
                char_table.worldBoss = false
                char_table.earthenTheater = false
                char_table.awakeningTheMachine = false
                char_table.phaseDiving = false
                char_table.ecologicalSuccession = false
                char_table.urgeToSurge = false
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
        self.main_frame:SetSize(self:CalculateXSizeNoGuidCheck(), sizey)

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
    local dungeon = " "
    local expire = nil
    local level = " "

    local guid = UnitGUID("player")

    C_MythicPlus.RequestCurrentAffixes()
    C_MythicPlus.RequestMapInfo()
    for k in pairs(constants.DUNGEONS) do
        C_MythicPlus.RequestMapInfo(k)
    end

    local maps = C_ChallengeMode.GetMapTable()
    for idx = 1, #maps do
        C_ChallengeMode.RequestLeaders(maps[idx])
    end

    local runHistory = C_MythicPlus.GetRunHistory(false, true)

    local function extractKeystoneInfo(slotItem)
        if slotItem.itemID == 180653 or slotItem.slotID == 151086 then
            local itemString = slotItem.hyperlink and slotItem.hyperlink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
            if itemString then
                local info = { strsplit(":", itemString) }
                local d = tonumber(info[2]) or nil
                local l = tonumber(info[3])
                local e = tonumber(info[4]) or nil
                if d and l then
                    return d, "+" .. l, e
                end
            end
        end
    end

    local function checkKhazAlgarEmissaryStatus()
        local khazAlgarEmissaryText = false
        local questIDs = {
            82449, 82452, 82453, 82458, 82482, 82483, 82485, 82486, 82487, 82488,
            82489, 82490, 82491, 82492, 82493, 82494, 82495, 82496, 82497, 82498,
            82499, 82500, 82501, 82502, 82503, 82504, 82505, 82506, 82507, 82508,
            82509, 82510, 82511, 82512, 82659, 82678, 82679, 82706, 82707, 82709,
            82711, 82712, 82746, 87417, 87419, 87422, 87423, 87424, 89514, 91052,
            91855
        }

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsOnQuest(QUEST_ID) then
                khazAlgarEmissaryText = "|cFFFBD910In Progress|r"
                return khazAlgarEmissaryText
            end
        end

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                khazAlgarEmissaryText = "|cFF00CF20Complete|r"
                return khazAlgarEmissaryText
            else
                khazAlgarEmissaryText = "|cFFFF0000Not Started|r"
            end
        end

        return khazAlgarEmissaryText
    end

    local function checkSpecialAssignmentStatus()
        local specialAssignmentsText = false
        local questIDs = { 82355, 82852, 82787, 83229, 81691, 82414, 82531, 81650, 85488, 85487 }

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                specialAssignmentsText = "|cFF00CF20Complete|r"
                break
            else
                specialAssignmentsText = "|cFFFF0000Incomplete|r"
            end
        end

        return specialAssignmentsText
    end

    local function checkAzjKahetPactStatus()
        local azjKahetPactText = false
        local questIDs = { 80670, 80671, 80672 }

        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                azjKahetPactText = "|cFF00CF20Complete|r"
                break
            else
                azjKahetPactText = "|cFFFF0000Incomplete|r"
            end
        end

        return azjKahetPactText
    end

    local function checkWorldBossStatus()
        local db2 = MyAltManagerDB
        if not db2 or not db2.data then
            return "|cFFFF0000Incomplete|r"
        end

        for _, charData in pairs(db2.data) do
            if charData.worldBoss == "|cFF00CF20Complete|r" then
                return "|cFF00CF20Complete|r"
            end
        end

        local questIDs = { 87354 }
        for _, QUEST_ID in ipairs(questIDs) do
            if C_QuestLog.IsQuestFlaggedCompleted(QUEST_ID) then
                for _, charData in pairs(db2.data) do
                    charData.worldBoss = "|cFF00CF20Complete|r"
                end
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

        local spent = info.totalEarned - info.quantity
        local rollingMax = math.max(info.quantity, info.maxQuantity - spent)
        return ("%d/%d"):format(info.quantity, rollingMax)
    end

    local keystone_found = false
    local keystone_details = "None"
    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(container)
        for slot = 1, slots do
            local slotItem = C_Container.GetContainerItemInfo(container, slot)
            if slotItem then
                local d, l, e = extractKeystoneInfo(slotItem)
                if d then
                    keystone_found = true
                    dungeon, level, expire = d, l, e
                    keystone_details = level .. " " .. (constants.DUNGEONS[dungeon] or tostring(dungeon))
                end
            end
        end
    end

    if not keystone_found then
        keystone_details = "None"
    end

    local khazAlgarEmissary = checkKhazAlgarEmissaryStatus()
    local azjKahetPacts = checkAzjKahetPactStatus()
    local worldBoss = checkWorldBossStatus()

    local earthenTheater = C_QuestLog.IsQuestFlaggedCompleted(83240) and true or false
    local collectingWax = C_QuestLog.IsQuestFlaggedCompleted(82946) and true or false
    local awakeningTheMachine = C_QuestLog.IsQuestFlaggedCompleted(83333) and true or false
    local spreadingTheLight = C_QuestLog.IsQuestFlaggedCompleted(76586) and true or false
    local urgeToSurge = C_QuestLog.IsQuestFlaggedCompleted(86775) and true or false
    local ecologicalSuccession = C_QuestLog.IsQuestFlaggedCompleted(85460) and true or false
    local phaseDiving = C_QuestLog.IsQuestFlaggedCompleted(91093) and true or false
    local hiddenTrove = C_QuestLog.IsQuestFlaggedCompleted(86371) and true or false

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

    local lfr_crests = GetRollingCurrencyProgress(constants.currencies.lfr_crests)
    local normal_crests = GetRollingCurrencyProgress(constants.currencies.normal_crests)
    local heroic_crests = GetRollingCurrencyProgress(constants.currencies.heroic_crests)
    local heroic_crests_current = GetCurrencyAmount(constants.currencies.heroic_crests)
    local mythic_crests = GetRollingCurrencyProgress(constants.currencies.mythic_crests)
    local mythic_crests_current = GetCurrencyAmount(constants.currencies.mythic_crests)
    local valorstones = GetCurrencyAmount(constants.currencies.valorstones) or 0
    local starlightSparks = GetRollingCurrencyProgress(constants.currencies.starlightSparks)
    local undercoin = GetCurrencyAmount(constants.currencies.undercoin) or 0
    local resonance_crystals = GetCurrencyAmount(constants.currencies.resonance_crystals) or 0
    local restored_coffer_keys = GetCurrencyAmount(constants.currencies.restored_coffer_keys) or 0
    local flame_blessed_iron = GetCurrencyAmount(constants.currencies.flameBlessedIron) or 0
    local untaintedManaCrystals = GetCurrencyAmount(constants.currencies.untaintedManaCrystals) or 0

    local catalystCharges = GetCurrencyAmount(constants.currencies.catalyst) or 0
    local catalystChargesMax = (C_CurrencyInfo.GetCurrencyInfo(constants.currencies.catalyst) or {}).maxQuantity or 0

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
    char_table.khazAlgarEmissary = khazAlgarEmissary
    char_table.phaseDiving = phaseDiving
    char_table.ecologicalSuccession = ecologicalSuccession
    char_table.urgeToSurge = urgeToSurge
    char_table.hiddenTrove = hiddenTrove
    char_table.azjKahetPacts = azjKahetPacts
    char_table.specialAssignment = specialAssignment
    char_table.spreadingTheLight = spreadingTheLight
    char_table.awakeningTheMachine = awakeningTheMachine
    char_table.earthenTheater = earthenTheater
    char_table.collectingWax = collectingWax
    char_table.worldBoss = worldBoss
    char_table.conquest = conquest
    char_table.forged_weapons = forged_weapons
    char_table.honor = honor
    char_table.bloody_tokens = bloody_tokens
    char_table.lfr_crests = lfr_crests
    char_table.normal_crests = normal_crests
    char_table.heroic_crests = heroic_crests
    char_table.heroic_crests_current = heroic_crests_current
    char_table.mythic_crests = mythic_crests
    char_table.mythic_crests_current = mythic_crests_current
    char_table.valorstones = valorstones
    char_table.starlightSparks = starlightSparks
    char_table.undercoin = undercoin
    char_table.resonance_crystals = resonance_crystals
    char_table.restored_coffer_keys = restored_coffer_keys
    char_table.untaintedManaCrystals = untaintedManaCrystals
    char_table.flame_blessed_iron = flame_blessed_iron
    char_table.weeklyCofferKeysCollected = weeklyCofferKeysCollected
    char_table.catalystCharges = string.format("%s / %s", catalystCharges, catalystChargesMax)
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
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, setId = GetItemInfo(invItem)
            if setId and constants.TIER_SETS[setId] then
                tierItems[slotId] = 1
            end
        end
    end

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(container)
        for slot = 1, slots do
            local slotItem = C_Container.GetContainerItemInfo(container, slot)
            if slotItem ~= nil then
                local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, setId = GetItemInfo(slotItem.itemID)
                if setId and constants.TIER_SETS[setId] then
                    tierItems[slot] = 1
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
    local completedDelves = C_WeeklyRewards.GetActivities(6)
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
    local completedRaids = C_WeeklyRewards.GetActivities(3)
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
    local completedDungeons = C_WeeklyRewards.GetActivities(1)
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
    local info = C_MythicPlus.GetRunHistory(false, true)

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
    local runHistory = C_MythicPlus.GetRunHistory(false, true)
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

-- ------------------------------------------------------------
-- UI content
-- ------------------------------------------------------------

function AltManager:CreateContent()
    self.main_frame.closeButton = CreateFrame("Button", "CloseButton", self.main_frame, "UIPanelCloseButton")
    self.main_frame.closeButton:ClearAllPoints()
    self.main_frame.closeButton:SetPoint("BOTTOMRIGHT", self.main_frame, "TOPRIGHT", -3, 2)
    self.main_frame.closeButton:SetScript("OnClick", function() AltManager:HideInterface() end)

    local column_table = {
        spacer_1 = {
            order = 1,
            label = "",
            data = function(_) return " " end,
        },
        name = {
            order = 1.1,
            label = constants.labels.NAME,
            data = function(alt_data) return alt_data.name .. " (" .. (alt_data.ilevel or 0) .. ")" end,
            color = function(alt_data) return RAID_CLASS_COLORS[alt_data.class] end,
        },
        realm = {
            order = 1.2,
            data = function(alt_data) return tostring(alt_data.realmName) .. "  " end,
            remove_button = function(alt_data) return self:CreateRemoveButton(function() AltManager:RemoveCharacterByGuid(alt_data.guid) end) end,
        },
        tier = {
            order = 1.3,
            label = constants.labels.TIER_SET,
            data = function(alt_data) return (tostring(alt_data.tierBonuses) or "No Set") end,
        },
        catalyst_charges = {
            order = 1.4,
            label = constants.labels.CATALYST_CHARGES,
            data = function(alt_data) return (alt_data.catalystCharges and tostring(alt_data.catalystCharges) or "0") end,
        },
        spacer_2 = {
            order = 2.0,
            label = "",
            data = function(_) return " " end,
        },
        mythic_title = {
            order = 2.1,
            label = constants.labels.KEYSTONE,
            title = true,
            data = function(_) return " " end,
        },
        mythic_rating = {
            order = 2.2,
            label = constants.labels.MYTHIC_RATING,
            data = function(alt_data) return tostring(alt_data.overallDungeonScore) or 0 end,
        },
        current_keystone = {
            order = 2.3,
            label = constants.labels.CURRENT_KEYSTONE,
            data = function(alt_data) return tostring(alt_data.keystone_details) or "None" end,
        },
        weekly_highest = {
            order = 2.4,
            label = constants.labels.WEEKLY_HIGHEST,
            data = function(alt_data) return tostring(alt_data.highestCompletedWeeklyKeystone) or " " end,
        },
        spacer_2_5 = {
            order = 2.5,
            label = "",
            data = function(_) return " " end,
        },
        great_vault_rewards = {
            order = 2.6,
            label = constants.labels.GREAT_VAULT_REWARDS,
            title = true,
            data = function(alt_data)
                return "|TInterface\\Icons\\inv_crestupgrade_ethereal_runed:12:12:0:0|t " .. tostring(alt_data.heroic_crests_current or 0)
                    .. " | |TInterface\\Icons\\inv_crestupgrade_ethereal_gilded:12:12:0:0|t " .. tostring(alt_data.mythic_crests_current or 0)
            end,
        },
        weekly_raid_rewards = {
            order = 2.7,
            label = constants.labels.WEEKLY_RAID_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyRaidRewards) or "|cFFFFCD440/2|r | |cFFFFCD440/4|r | |cFFFFCD440/6|r" end,
        },
        weekly_key_rewards = {
            order = 2.8,
            label = constants.labels.WEEKLY_DUNGEON_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyDungeonRewards) or "|cFFFFCD440/1|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r" end,
        },
        weekly_delve_rewards = {
            order = 2.9,
            label = constants.labels.WEEKLY_DELVE_REWARDS,
            data = function(alt_data) return tostring(alt_data.weeklyDelveRewards) or "|cFFFFCD440/2|r | |cFFFFCD440/4|r | |cFFFFCD440/8|r" end,
        },
        spacer_2_9_1 = {
            order = 2.91,
            label = "",
            data = function(_) return " " end,
        },
        pvp_data = {
            order = 2.92,
            label = constants.labels.PVP,
            title = true,
            data = function(_) return " " end,
        },
        pvp_honor = {
            order = 2.93,
            label = constants.labels.HONOR,
            data = function(alt_data) return (alt_data.honor and tostring(alt_data.honor) or "0") end,
        },
        pvp_conquest = {
            order = 2.94,
            label = constants.labels.CONQUEST,
            data = function(alt_data) return (alt_data.conquest and tostring(alt_data.conquest) or "0") end,
        },
        pvp_conquest_earned = {
            order = 2.95,
            label = constants.labels.FORGED_WEAPONS,
            data = function(alt_data) return (alt_data.forged_weapons and tostring(alt_data.forged_weapons) or "|cFFFF0000Incomplete|r") end,
        },
        pvp_bloody_tokens = {
            order = 2.96,
            label = constants.labels.BLOODY_TOKENS,
            data = function(alt_data) return (alt_data.bloody_tokens and tostring(alt_data.bloody_tokens) or "0") end,
        },
        spacer_3 = {
            order = 3.0,
            label = "",
            data = function(_) return " " end,
        },
        weekly_quests = {
            order = 3.1,
            label = constants.labels.WEEKLY_QUESTS,
            title = true,
            data = function(_) return " " end,
        },
        khaz_algar_emissary = {
            order = 3.2,
            label = constants.labels.KHAZ_ALGAR_EMISSARY,
            data = function(alt_data) return (alt_data.khazAlgarEmissary and tostring(alt_data.khazAlgarEmissary) or "|cFFFF0000Not Started|r") end,
        },
        ecological_succession = {
            order = 3.22,
            label = constants.labels.ECOLOGICAL_SUCCESSION,
            data = function(alt_data) return alt_data.ecologicalSuccession and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        urge_to_surge = {
            order = 3.23,
            label = constants.labels.URGE_TO_SURGE,
            data = function(alt_data) return alt_data.urgeToSurge and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        hidden_trove = {
            order = 3.24,
            label = constants.labels.HIDDEN_TROVE,
            data = function(alt_data) return alt_data.hiddenTrove and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
        },
        world_boss = {
            order = 3.3,
            label = constants.labels.WORLD_BOSS,
            data = function(alt_data) return (alt_data.worldBoss and tostring(alt_data.worldBoss) or "|cFFFF0000Incomplete|r") end,
        },
        spacer_4 = {
            order = 4.0,
            label = "",
            data = function(_) return " " end,
        },
        currencies = {
            order = 5.1,
            label = constants.labels.CURRENCIES,
            title = true,
            data = function(_) return " " end,
        },
        starlightSparks = {
            order = 5.2,
            label = constants.labels.STARLIGHT_SPARKS,
            data = function(alt_data) return (alt_data.starlightSparks and tostring(alt_data.starlightSparks) or "0") end,
        },
        valorstones = {
            order = 5.21,
            label = constants.labels.VALORSTONES,
            data = function(alt_data) return (alt_data.valorstones and tostring(alt_data.valorstones) or "0") end,
        },
        runed_crests = {
            order = 5.22,
            label = constants.labels.HEROIC_CRESTS,
            data = function(alt_data) return (alt_data.heroic_crests and tostring(alt_data.heroic_crests) or "0") end,
        },
        gilded_crests = {
            order = 5.23,
            label = constants.labels.MYTHIC_CRESTS,
            data = function(alt_data) return (alt_data.mythic_crests and tostring(alt_data.mythic_crests) or "0") end,
        },
        restored_coffer_keys = {
            order = 5.3,
            label = constants.labels.RESTORED_COFFER_KEY,
            data = function(alt_data) return (alt_data.restored_coffer_keys and tostring(alt_data.restored_coffer_keys) or "0") end,
        },
        undercoin = {
            order = 5.31,
            label = constants.labels.UNDERCOIN,
            data = function(alt_data) return (alt_data.undercoin and tostring(alt_data.undercoin) or "0") end,
        },
        untaintedManaCrystals = {
            order = 5.32,
            label = constants.labels.UNTAINTED_MANA_CRYSTALS,
            data = function(alt_data) return (alt_data.untaintedManaCrystals and tostring(alt_data.untaintedManaCrystals) or "0") end,
        },
    }

    self.columns_table = column_table

    local font_height = 14
    local label_column = self.main_frame.label_column or CreateFrame("Button", nil, self.main_frame)
    if not self.main_frame.label_column then self.main_frame.label_column = label_column end
    label_column:SetSize(per_alt_x, sizey)
    label_column:SetPoint("TOPLEFT", self.main_frame, "TOPLEFT", 4, -1)

    local i = 1
    for _, row in spairs(self.columns_table, function(t, a, b) return t[a].order < t[b].order end) do
        if row.label then
            if row.label ~= "" and not row.title then
                row.label = row.label .. ":"
            elseif row.label == "" then
                row.label = " "
            end
            self:CreateFontFrame(self.main_frame, per_alt_x, font_height, label_column, -(i - 1) * font_height, row.label, "RIGHT")
            self.main_frame.lowest_point = -(i - 1) * font_height
        end
        i = i + 1
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

        anchor_frame:SetSize(per_alt_x, sizey)
        self.main_frame.alt_columns[alt].label_columns = self.main_frame.alt_columns[alt].label_columns or {}
        local label_columns = self.main_frame.alt_columns[alt].label_columns

        local i = 1
        for _, column in spairs(self.columns_table, function(t, a, b) return t[a].order < t[b].order end) do
            if type(column.data) == "function" then
                local current_row = label_columns[i] or self:CreateFontFrame(anchor_frame, per_alt_x, column.font_height or font_height, anchor_frame, -(i - 1) * font_height, column.data(alt_data), "CENTER")
                if not self.main_frame.alt_columns[alt].label_columns[i] then
                    self.main_frame.alt_columns[alt].label_columns[i] = current_row
                end

                if column.color then
                    local color = column.color(alt_data)
                    current_row:GetFontString():SetTextColor(color.r, color.g, color.b, 1)
                end

                current_row:SetText(column.data(alt_data))

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

function AltManager:HideInterface()
    self.main_frame:Hide()
end

function AltManager:ShowInterface()
    self.main_frame:Show()
    if self:CanCollectNow() then
        self:StoreData(self:CollectData())
    end
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
    if not self.resetDays then
        local region = self:GetRegion()
        if not region then return nil end
        self.resetDays = {}
        self.resetDays.DLHoffset = 0
        if region == "US" then
            self.resetDays["2"] = true
            self.resetDays.DLHoffset = -3
        elseif region == "EU" then
            self.resetDays["3"] = true
        elseif region == "CN" or region == "KR" or region == "TW" then
            self.resetDays["4"] = true
        else
            self.resetDays["2"] = true
        end
    end
    local offset = (self:GetServerOffset() + self.resetDays.DLHoffset) * 3600
    local nightlyReset = self:GetNextDailyResetTime()
    if not nightlyReset then return nil end
    while not self.resetDays[date("%w", nightlyReset + offset)] do
        nightlyReset = nightlyReset + 24 * 3600
    end
    return nightlyReset
end

function AltManager:GetNextDailyResetTime()
    local resettime = GetQuestResetTime()
    if not resettime or resettime <= 0 or resettime > 24 * 3600 + 30 then
        return nil
    end
    return time() + resettime
end

function AltManager:GetServerOffset()
    local serverDay = C_DateAndTime.GetCurrentCalendarTime().weekday - 1
    local localDay = tonumber(date("%w"))
    local serverHour, serverMinute = GetGameTime()
    local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
    if serverDay == (localDay + 1) % 7 then
        serverHour = serverHour + 24
    elseif localDay == (serverDay + 1) % 7 then
        localHour = localHour + 24
    end
    local server = serverHour + serverMinute / 60
    local localT = localHour + localMinute / 60
    local offset = floor((server - localT) * 2 + 0.5) / 2
    return offset
end

function AltManager:GetRegion()
    if not self.region then
        local reg = GetCVar("portal")
        if reg == "public-test" then
            reg = "US"
        end
        if not reg or #reg ~= 2 then
            local gcr = GetCurrentRegion()
            reg = gcr and ({ "US", "KR", "EU", "TW", "CN" })[gcr]
        end
        if not reg or #reg ~= 2 then
            reg = (GetCVar("realmList") or ""):match("^(%a+)%.")
        end
        if not reg or #reg ~= 2 then
            reg = (GetRealmName() or ""):match("%((%a%a)%)")
        end
        reg = reg and reg:upper()
        if reg and #reg == 2 then
            self.region = reg
        end
    end
    return self.region
end

function AltManager:GetWoWDate()
    local hour = tonumber(date("%H"))
    local day = C_DateAndTime.GetCurrentCalendarTime().weekday
    return day, hour
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
