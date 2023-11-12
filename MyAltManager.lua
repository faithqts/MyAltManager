local _, AltManager = ...;

_G["AltManager"] = AltManager;

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 2020-10-14
-- updates for Dragonflight by: Faith - Frostmourne, 2021-2023
-- Last edit: 2023-11-12

local sizey = 425;
local xoffset = 0;
local yoffset = 50;
local addon = "MyAltManager";
local numel = table.getn;

local per_alt_x = 170;
local ilvl_text_size = 14;
local remove_button_size = 18;
local min_x_size = 300;

local constants = {};

constants.config = {};
constants['config'].MIN_LEVEL = 70;

constants.labels = {
    NAME = "",
    WEEKLY_HIGHEST = "Weekly Highest",
    CURRENT_KEYSTONE = "Current Keystone",
    WEEKLY_QUESTS = "Weekly Quests",
    WEEKLY_EVENTS = "Weekly Events",
    AIDING_THE_ACCORD = "Aiding The Accord",
    KEYSTONE = "Mythic+",
    MYTHIC_RATING = "Overall Rating",
    WEEKLY_REWARDS = "Weekly Vault",
    COMMUNITY_FEAST = "Community Feast",
    SPARKS_OF_LIFE = "Sparks of Life",
    TIER_SET = "Tier 31",
    CATALYST_CHARGES = "Catalyst Charges",
    CURRENCIES = "Currencies",
    WHELPLINGS_CREST = "Whelplings Crest",
    DRAKES_CREST = "Drakes Crest",
    WYRMS_CREST = "Wyrms Crest",
    ASPECTS_CREST = "Aspects Crest",
    FLIGHTSTONES = "Flightstones",
    ALLY_LOAMM_NIFFEN = "Ally: Loamm Niffen",
    ALLY_DREAM_WARDENS = "Ally: Dream Wardens",
    THE_SUPERBLOOM = "The Superbloom",
    BLOOMING_DREAMSEEDS = "Blooming Dreamseeds"
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
}

constants.VAULT_ILVL = {
	454,
	457,
	460,
	460,
	463,
	463,
	467,
	467,
	470,
	470,
	473,
	473,
	473,
	476,
	476,
	476,
	480,
	480,
	483
};

constants.TIER_SETS = {
    -- Death Knight
    ["207198"] = true,
    ["207199"] = true,
    ["207200"] = true,
    ["207201"] = true,
    ["207203"] = true,

    -- Demon Hunter
    ["207261"] = true,
    ["207262"] = true,
    ["207263"] = true,
    ["207264"] = true,
    ["207266"] = true,

    -- Druid
    ["207252"] = true,
    ["207253"] = true,
    ["207254"] = true,
    ["207255"] = true,
    ["207257"] = true,

    -- Evoker
    ["207225"] = true,
    ["207226"] = true,
    ["207227"] = true,
    ["207228"] = true,
    ["207230"] = true,

    -- Hunter
    ["207216"] = true,
    ["207217"] = true,
    ["207218"] = true,
    ["207219"] = true,
    ["207221"] = true,

    -- Mage
    ["207288"] = true,
    ["207289"] = true,
    ["207290"] = true,
    ["207291"] = true,
    ["207293"] = true,

    -- Monk
    ["207243"] = true,
    ["207244"] = true,
    ["207245"] = true,
    ["207246"] = true,
    ["207248"] = true,

    -- Paladin
    ["207189"] = true,
    ["207190"] = true,
    ["207191"] = true,
    ["207192"] = true,
    ["207194"] = true,

    -- Priest
    ["207279"] = true,
    ["207280"] = true,
    ["207281"] = true,
    ["207282"] = true,
    ["207284"] = true,

    -- Rogue
    ["207234"] = true,
    ["207235"] = true,
    ["207236"] = true,
    ["207237"] = true,
    ["207239"] = true,

    -- Shaman
    ["207207"] = true,
    ["207208"] = true,
    ["207209"] = true,
    ["207210"] = true,
    ["207212"] = true,

    -- Warlock
    ["207270"] = true,
    ["207271"] = true,
    ["207272"] = true,
    ["207273"] = true,
    ["207275"] = true,

    -- Warrior
    ["207180"] = true,
    ["207181"] = true,
    ["207182"] = true,
    ["207183"] = true,
    ["207185"] = true,
}

constants.TIER_SLOTS = {
    [1] = "Helm",
    [3] = "Shoulders",
    [5] = "Chest",
    [7] = "Pants",
    [10] = "Gloves",
}

constants.VERSION = "10.2.0.0";

local function GetCurrencyAmount(id)
	local info = C_CurrencyInfo.GetCurrencyInfo(id)
	return info.quantity;
end

SLASH_ALTMANAGER1 = "/alts";

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
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
	for k, v in pairs(t) do c = c + 1 end
	return c
end

function SlashCmdList.ALTMANAGER(cmd, editbox)
	local rqst, arg = strsplit(' ', cmd)
	if rqst == "help" then
		print("Alt Manager help:")
		print("   \"/alts purge\" to remove all stored data.")
		print("   \"/alts remove name\" to remove characters by name.")
	elseif rqst == "purge" then
		AltManager:Purge();
	elseif rqst == "remove" then
		AltManager:RemoveCharactersByName(arg)
	else
		AltManager:ShowInterface();
	end
end

do
	local main_frame = CreateFrame("frame", "AltManagerFrame", UIParent);
	AltManager.main_frame = main_frame;
	main_frame:SetFrameStrata("MEDIUM");
	main_frame.background = main_frame:CreateTexture(nil, "BACKGROUND");
	main_frame.background:SetAllPoints();
	main_frame.background:SetDrawLayer("ARTWORK", 1);
	main_frame.background:SetColorTexture(0, 0, 0, 0.7);
	
	main_frame:ClearAllPoints();
	main_frame:SetPoint("CENTER", UIParent, "CENTER", xoffset, yoffset);
	
	main_frame:RegisterEvent("ADDON_LOADED");
	main_frame:RegisterEvent("PLAYER_LOGIN");
	main_frame:RegisterEvent("PLAYER_LOGOUT");
	main_frame:RegisterEvent("QUEST_TURNED_IN");
	main_frame:RegisterEvent("BAG_UPDATE_DELAYED");
	main_frame:RegisterEvent("ARTIFACT_XP_UPDATE");
	main_frame:RegisterEvent("CHAT_MSG_CURRENCY");
	main_frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	main_frame:RegisterEvent("PLAYER_LEAVING_WORLD");

	main_frame:SetScript("OnEvent", function(self, ...)
		local event, loaded = ...;
		if event == "ADDON_LOADED" then
			if addon == loaded then
      			AltManager:OnLoad();
			end
		end
		if event == "PLAYER_LOGIN" then
        	AltManager:OnLogin();
			AltManager:StoreData(data);
		end
		if event == "PLAYER_LEAVING_WORLD" then
			local data = AltManager:CollectData(false);
			AltManager:StoreData(data);
		end
		if (event == "BAG_UPDATE_DELAYED" or event == "QUEST_TURNED_IN" or event == "CHAT_MSG_CURRENCY" or event == "CURRENCY_DISPLAY_UPDATE") and AltManager.addon_loaded then
			local data = AltManager:CollectData(false);
			AltManager:StoreData(data);
		end
		
	end)

	main_frame:EnableKeyboard(true);
	main_frame:SetScript("OnKeyDown", function(self, key) if key == "ESCAPE" then main_frame:SetPropagateKeyboardInput(false); else main_frame:SetPropagateKeyboardInput(true); end end )
	main_frame:SetScript("OnKeyUp", function(self, key) if key == "ESCAPE" then  AltManager:HideInterface() end end);
	
	main_frame:Hide();
end

function AltManager:InitDB()
	local t = {};
	t.alts = 0;
	t.data = {};
	return t;
end

function AltManager:CalculateXSizeNoGuidCheck()
	local alts = MyAltManagerDB.alts;
	return max((alts + 1) * per_alt_x, min_x_size)
end

function AltManager:CalculateXSize()
	return self:CalculateXSizeNoGuidCheck()
end

function AltManager:OnLogin()
	self:ValidateReset();
	self:StoreData(self:CollectData());
  
	self.main_frame:SetSize(self:CalculateXSize(), sizey);
	self.main_frame.background:SetAllPoints();
	
	AltManager:CreateContent();
	AltManager:MakeTopBottomTextures(self.main_frame);
	AltManager:MakeBorder(self.main_frame, 5);
end

function AltManager:PurgeOldVersions()
	if MyAltManagerDB == nil or MyAltManagerDB.data == nil then return end
	local remove = {}
	for alt_guid, alt_data in spairs(MyAltManagerDB.data, function(t, a, b) return t[a].ilevel > t[b].ilevel end) do
		if alt_data.version == nil or alt_data.version < constants.config.VERSION then
			table.insert(remove, alt_guid)
		end
	end
	for k, v in pairs(remove) do
		MyAltManagerDB.alts = MyAltManagerDB.alts - 1;
		MyAltManagerDB.data[v] = nil
	end
end

function AltManager:OnLoad()
	self.main_frame:UnregisterEvent("ADDON_LOADED");
	
	MyAltManagerDB = MyAltManagerDB or self:InitDB();

	self:PurgeOldVersions();

	if MyAltManagerDB.alts ~= true_numel(MyAltManagerDB.data) then
		print("Altcount inconsistent, using", true_numel(MyAltManagerDB.data))
		MyAltManagerDB.alts = true_numel(MyAltManagerDB.data)
	end

	self.addon_loaded = true
	C_MythicPlus.RequestRewards();
	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
	for k,v in pairs(constants.DUNGEONS) do
		C_MythicPlus.RequestMapInfo(k);
	end
end

function AltManager:CreateFontFrame(parent, x_size, height, relative_to, y_offset, label, justify)
	local f = CreateFrame("Button", nil, parent);
	f:SetSize(x_size, height);
	f:SetNormalFontObject(GameFontHighlightMedium)
	f:SetText(label)
	f:SetPoint("TOPLEFT", relative_to, "TOPLEFT", 0, y_offset);
	f:GetFontString():SetJustifyH(justify);
	f:GetFontString():SetJustifyV("CENTER");
	f:SetPushedTextOffset(0, 0);
	f:GetFontString():SetWidth(170)
	f:GetFontString():SetHeight(16)
	
	return f;
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
	if not db then return end;
	if not db.data then return end;
	
	local keyset = {}
	for k in pairs(db.data) do
		table.insert(keyset, k)
	end
	
	for alt = 1, db.alts do
		local expiry = db.data[keyset[alt]].expires or 0;
		local char_table = db.data[keyset[alt]];
		if time() > expiry then
			char_table.dungeon = " ";
			char_table.level = " ";
			char_table.runHistory = nil;
			char_table.highestCompletedWeeklyKeystone = nil;
			char_table.completedWeeklyKeystoneRewards = nil;
			char_table.expires = self:GetNextWeeklyResetTime();
			char_table.accordWeekly = false;
			char_table.sparksOfLife = false;
			char_table.communityFeast = false;
			char_table.allyDreamWardens = false;
			char_table.allyLoammNiffen = false;
			char_table.theSuperbloom = false;
			char_table.bloomingDreamseeds = false;
		end
	end
end

function AltManager:Purge()
	MyAltManagerDB = self:InitDB();
end

function AltManager:RemoveCharactersByName(name)
	local db = MyAltManagerDB;

	local indices = {};
	for guid, data in pairs(db.data) do
		if db.data[guid].name == name then
			indices[#indices+1] = guid
		end
	end

	db.alts = db.alts - #indices;
	for i = 1,#indices do
		db.data[indices[i]] = nil
	end

	print("Found " .. (#indices) .. " characters by the name of " .. name)
	print("Please reload ui to update the displayed info.")

end

function AltManager:RemoveCharacterByGuid(index)
	local db = MyAltManagerDB;

	if db.data[index] == nil then return end

	local delete = function()
		if db.data[index] == nil then return end
		db.alts = db.alts - 1;
		db.data[index] = nil
		self.main_frame:SetSize(self:CalculateXSizeNoGuidCheck(), sizey);
		if self.main_frame.alt_columns ~= nil then
			local count = #self.main_frame.alt_columns
			for j = 0,count-1 do
				if self.main_frame.alt_columns[count-j]:IsShown() then
					self.main_frame.alt_columns[count-j]:Hide()
					break
				end
			end
			
			if self.main_frame.remove_buttons ~= nil and self.main_frame.remove_buttons[index] ~= nil then
				self.main_frame.remove_buttons[index]:Hide()
			end
		end
		self:UpdateStrings()
	end

	delete();

end

function AltManager:CommaValues(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function AltManager:StoreData(data)

	if not data or not data.guid then
		return
	end

	if UnitLevel('player') < constants.config.MIN_LEVEL then return end;

	local db = MyAltManagerDB;
	local guid = data.guid;

	db.data = db.data or {};
	
	local update = false;
	for k, v in pairs(db.data) do
		if k == guid then
			update = true;
		end
	end
	
	if not update then
		db.data[guid] = data;
		db.alts = db.alts + 1;
	else
		db.data[guid] = data;
	end
end

function AltManager:CollectData()
	
	if UnitLevel('player') < constants.config.MIN_LEVEL then return	end

	_, i = GetAverageItemLevel()
	if i == 0 then return end

	local name = UnitName('player')
	local _, class = UnitClass('player')
	local dungeon = nil;
	local expire = nil;
	local level = nil;
	local highest_mplus = 0;

	local guid = UnitGUID('player');

	C_MythicPlus.RequestCurrentAffixes()
	C_MythicPlus.RequestMapInfo()

	for k, v in pairs(constants.DUNGEONS) do
		C_MythicPlus.RequestMapInfo(k)
	end

	local maps = C_ChallengeMode.GetMapTable()
	for i = 1, #maps do
		C_ChallengeMode.RequestLeaders(maps[i])
	end

	local runHistory = C_MythicPlus.GetRunHistory(false, true)

	local function extractKeystoneInfo(slotItem)
		if slotItem.itemID == 180653 or slotItem.slotID == 151086 then
			local itemString = slotItem.hyperlink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
			if itemString then
				local info = { strsplit(":", itemString) }
				local dungeon = tonumber(info[2]) or nil
				local level = "+" .. tonumber(info[3]) or nil
				local expire = tonumber(info[4]) or nil
				return dungeon, level, expire
			end
		end
	end

	local keystone_found = false
	for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = C_Container.GetContainerNumSlots(container)
		for slot = 1, slots do
			local slotItem = C_Container.GetContainerItemInfo(container, slot)
			if slotItem then
				local dungeon, level, expire = extractKeystoneInfo(slotItem)
				if dungeon then
					keystone_found = true
					keystone_details = level .. " " .. constants.DUNGEONS[dungeon]
				end
			end
		end
	end
  
	if not keystone_found then
		keystone_details = "None"
	end

	local accordWeekly = false
	local accordWeeklyText = false
	if C_QuestLog.IsOnQuest(70750) then
		local questInfo = C_QuestLog.GetQuestObjectives(70750);
		local progress = questInfo[1].numFulfilled;
		accordWeeklyText = "|cFFFBD910" .. progress .. "/3000|r";
	elseif C_QuestLog.IsOnQuest(72068) then
		local questInfo = C_QuestLog.GetQuestObjectives(72068);
		local progress = questInfo[2].numFulfilled;
		accordWeeklyText = "|cFFFBD910" .. progress .. "/3000|r";
	elseif C_QuestLog.IsOnQuest(72373) then
		local questInfo = C_QuestLog.GetQuestObjectives(72373);
		local progress = questInfo[2].numFulfilled;
		accordWeeklyText = "|cFFFBD910" .. progress .. "/3000|r";
	elseif C_QuestLog.IsOnQuest(72374) then
		local questInfo = C_QuestLog.GetQuestObjectives(72374);
		local progress = questInfo[2].numFulfilled;
		accordWeeklyText = "|cFFFBD910" .. progress .. "/3000|r";
	elseif C_QuestLog.IsOnQuest(72375) then
		local questInfo = C_QuestLog.GetQuestObjectives(72375);
		local progress = questInfo[2].numFulfilled;
		accordWeeklyText = "|cFFFBD910" .. progress .. "/3000|r";
	elseif C_QuestLog.IsQuestFlaggedCompleted(70750) or C_QuestLog.IsQuestFlaggedCompleted(72068) or C_QuestLog.IsQuestFlaggedCompleted(72373) or C_QuestLog.IsQuestFlaggedCompleted(72374) or C_QuestLog.IsQuestFlaggedCompleted(72375) then
		accordWeeklyText = "|cFF00CF20Complete|r"
		accordWeekly = true
	else
		accordWeeklyText = "|cFFFF0000Not Started|r";
	end

	local allyDreamWardens = false
	if C_QuestLog.IsQuestFlaggedCompleted(78444) then
		allyDreamWardens = true
	end

	local allyLoammNiffen = false
	if C_QuestLog.IsQuestFlaggedCompleted(75665) then
		allyLoammNiffen = true
	end

	local theSuperbloom = false
	if C_QuestLog.IsQuestFlaggedCompleted(78319) then
		theSuperbloom = true
	end

	local bloomingDreamseeds = false
	if C_QuestLog.IsQuestFlaggedCompleted(78821) then
		bloomingDreamseeds = true
	end

	local communityFeast = false
	if C_QuestLog.IsQuestFlaggedCompleted(70893) then
		communityFeast = true
	end

	local sparksOfLife = false
	local sparksOfLifeText = false
	if C_QuestLog.IsOnQuest(72646) then
		local questInfo = C_QuestLog.GetQuestObjectives(72646);
		local progress = questInfo[1].numFulfilled;
		sparksOfLifeText = "|cFFFBD910" .. progress .. "/100|r";
	elseif C_QuestLog.IsOnQuest(72647) then
		local questInfo = C_QuestLog.GetQuestObjectives(72647);
		local progress = questInfo[1].numFulfilled;
		sparksOfLifeText = "|cFFFBD910" .. progress .. "/100|r";
	elseif C_QuestLog.IsOnQuest(72648) then
		local questInfo = C_QuestLog.GetQuestObjectives(72648);
		local progress = questInfo[1].numFulfilled;
		sparksOfLifeText = "|cFFFBD910" .. progress .. "/100|r";
	elseif C_QuestLog.IsOnQuest(72649) then
		local questInfo = C_QuestLog.GetQuestObjectives(72649);
		local progress = questInfo[1].numFulfilled;
		sparksOfLifeText = "|cFFFBD910" .. progress .. "/100|r";
	elseif C_QuestLog.IsQuestFlaggedCompleted(72646) or C_QuestLog.IsQuestFlaggedCompleted(72647) or C_QuestLog.IsQuestFlaggedCompleted(72648) or C_QuestLog.IsQuestFlaggedCompleted(72649) then
		sparksOfLifeText = "|cFF00CF20Complete|r"
		sparksOfLife = true
	else
		sparksOfLifeText = "|cFFFF0000Not Started|r";
	end
	
	local _, ilevel = GetAverageItemLevel();

	local whelpCrests = GetCurrencyAmount(2706);
	local drakeCrests = GetCurrencyAmount(2707);
	local wyrmCrests = GetCurrencyAmount(2708);
	local aspectCrests = GetCurrencyAmount(2709);
	local flightstones = GetCurrencyAmount(2245);

	local catalystCharges = (C_CurrencyInfo.GetCurrencyInfo(2533).quantity or 0);
	local catalystChargesMax = (C_CurrencyInfo.GetCurrencyInfo(2533).maxQuantity or 0);

	local char_table = {}

	char_table.guid = UnitGUID('player')
	char_table.name = name
	char_table.class = class
	char_table.ilevel = math.floor(ilevel)
	char_table.charLevel = UnitLevel('player')
	char_table.realmName = GetRealmName()
	char_table.dungeon = dungeon
	char_table.level = level
	char_table.keystone_details = keystone_details
	char_table.runHistory = runHistory
	char_table.highestCompletedWeeklyKeystone = self:GetHighestCompletedWeeklyKeystone()
	char_table.completedWeeklyKeystoneRewards = self:GetWeeklyKeystoneVaultRewards()
	char_table.tierBonuses = self:GetTierBonuses()
	char_table.overallDungeonScore = self:GetOverallDungeonScore()
	char_table.accordWeekly = accordWeekly
	char_table.accordWeeklyText = accordWeeklyText
	char_table.communityFeast = communityFeast
	char_table.whelpCrests = whelpCrests
	char_table.drakeCrests = drakeCrests
	char_table.wyrmCrests = wyrmCrests
	char_table.aspectCrests = aspectCrests
	char_table.flightstones = flightstones
	char_table.sparksOfLife = sparksOfLife
	char_table.sparksOfLifeText = sparksOfLifeText
	char_table.catalystCharges = string.format("%s / %s", catalystCharges, catalystChargesMax)
	char_table.allyDreamWardens = allyDreamWardens
	char_table.allyLoammNiffen = allyLoammNiffen
	char_table.theSuperbloom = theSuperbloom
	char_table.bloomingDreamseeds = bloomingDreamseeds
	char_table.version = constants.VERSION
	char_table.expires = self:GetNextWeeklyResetTime()
	char_table.dataObtained = time()
	char_table.timeUntilReset = C_DateAndTime.GetSecondsUntilDailyReset()

	return char_table
end

function AltManager:GetTierBonuses()
    local tierText = ""
    local tierCount = 0
    local tierItems = {}

    for _, slotID in pairs(constants.TIER_SLOTS) do
        local itemID = GetInventoryItemID("player", slotID)
        if constants.TIER_SETS[itemID] then
            tierItems[itemID] = 1
        end
    end

    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(container)
        for slot = 1, slots do
            local slotItem = C_Container.GetContainerItemInfo(container, slot)
            if slotItem and constants.TIER_SETS[slotItem.itemID] then
                tierItems[slotItem.itemID] = 1
            end
        end
    end

    for _, _ in pairs(tierItems) do
        tierCount = tierCount + 1
    end

    if tierCount > 0 then
        tierCount = math.min(tierCount, 4)
        tierText = tierCount .. "/4 Set"
    else
        tierText = "No Set"
    end

    return tierText
end

function AltManager:UpdateStrings()
	local font_height = 14;
	local db = MyAltManagerDB;
	
	local keyset = {}
	for k in pairs(db.data) do
		table.insert(keyset, k)
	end
	
	self.main_frame.alt_columns = self.main_frame.alt_columns or {};
	
	local alt = 0
	for alt_guid, alt_data in spairs(db.data, function(t, a, b) return t[a].ilevel > t[b].ilevel end) do
		alt = alt + 1
		local anchor_frame = self.main_frame.alt_columns[alt] or CreateFrame("Button", nil, self.main_frame);
		if not self.main_frame.alt_columns[alt] then
			self.main_frame.alt_columns[alt] = anchor_frame;
			self.main_frame.alt_columns[alt].guid = alt_guid
			anchor_frame:SetPoint("TOPLEFT", self.main_frame, "TOPLEFT", per_alt_x * alt, -1);
		end
		anchor_frame:SetSize(per_alt_x, sizey);
		self.main_frame.alt_columns[alt].label_columns = self.main_frame.alt_columns[alt].label_columns or {};
		local label_columns = self.main_frame.alt_columns[alt].label_columns;
		local i = 1;
		for column_iden, column in spairs(self.columns_table, function(t, a, b) return t[a].order < t[b].order end) do
			if type(column.data) == "function" then
				local current_row = label_columns[i] or self:CreateFontFrame(anchor_frame, per_alt_x, column.font_height or font_height, anchor_frame, -(i - 1) * font_height, column.data(alt_data), "CENTER");
				if not self.main_frame.alt_columns[alt].label_columns[i] then
					self.main_frame.alt_columns[alt].label_columns[i] = current_row;
				end
				if column.color then
					local color = column.color(alt_data)
					current_row:GetFontString():SetTextColor(color.r, color.g, color.b, 1);
				end
				current_row:SetText(column.data(alt_data))
				if column.font then
					current_row:GetFontString():SetFont(column.font, ilvl_text_size)
				end
				if column.justify then
					current_row:GetFontString():SetJustifyV(column.justify);
				end
				if column.remove_button ~= nil then
					self.main_frame.remove_buttons = self.main_frame.remove_buttons or {}
					local extra = self.main_frame.remove_buttons[alt_data.guid] or column.remove_button(alt_data)
					if self.main_frame.remove_buttons[alt_data.guid] == nil then 
						self.main_frame.remove_buttons[alt_data.guid] = extra
					end
					extra:SetParent(current_row)
					extra:SetPoint("TOPRIGHT", current_row, "TOPRIGHT", -18, 2 );
					extra:SetPoint("BOTTOMRIGHT", current_row, "TOPRIGHT", -18, -remove_button_size+6);
					extra:SetFrameLevel(current_row:GetFrameLevel() + 1)
					extra:Show();
				end
			end
			i = i + 1
		end
		
	end
	
end

function AltManager:GetOverallDungeonScore()
	local overallDungeonScore = C_ChallengeMode.GetOverallDungeonScore()
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(overallDungeonScore)
	local r, g, b = color.r * 255, color.g * 255, color.b * 255

	local colorString = string.format("|cff%02x%02x%02x", r, g, b)
	return colorString .. overallDungeonScore .. "|r"
end

function AltManager:GetHighestCompletedWeeklyKeystone()
    local info = C_MythicPlus.GetRunHistory(false, true)
    local keys, dungeons = {}, {}

    for _, run in ipairs(info) do
        tinsert(keys, run.level)
        tinsert(dungeons, run.mapChallengeModeID)
    end

    table.sort(keys, function(a, b) return b < a end)
    table.sort(dungeons, function(a, b) return b < a end)

    local level, dungeon = keys[1], dungeons[1]

    if level == 0 then
        return " "
    elseif level and level > 0 then
        local color
        if level >= 20 then
            color = "|cFFFF8000"
        elseif level >= 15 then
            color = "|cFFA335EE"
        elseif level >= 10 then
            color = "|cFF0070DD"
        elseif level >= 7 then
            color = "|cFF1EFF00"
        elseif level >= 2 then
            color = "|cFFFFFFFF"
        end
        return "+" .. level .. " " .. constants.DUNGEONS[dungeon] .. "|r"
    else
        return "None"
    end
end

function AltManager:GetLowestLevelInTopRuns(numRuns)
    local runHistory = C_MythicPlus.GetRunHistory(false, true)
    table.sort(runHistory, function(left, right) return left.level > right.level end)

    local lowestLevel = runHistory[1] and runHistory[1].level or nil
    local lowestCount = 0

    for i = 2, math.min(numRuns, #runHistory) do
        local run = runHistory[i]

        if lowestLevel == run.level then
            lowestCount = lowestCount + 1
        else
            break
        end
    end

    return lowestLevel
end

function AltManager:GetWeeklyKeystoneVaultRewards()
    local keystoneHistory = C_MythicPlus.GetRunHistory(false, true)
    local keystoneTotal = #keystoneHistory
    local keystoneRewardSlotOne, keystoneRewardSlotTwo, keystoneRewardSlotThree = 0, 0, 0
    local keystoneRewards = "|cFFFFCD440/8|r | |cFFFFCD440/8|r | |cFFFFCD440/8|r"

    if keystoneTotal >= 8 then
        keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 20) + 1] .. "|r"
        keystoneRewardSlotTwo = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(4)), 20) + 1] .. "|r"
        keystoneRewardSlotThree = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(keystoneTotal)), 20) + 1] .. "|r"
        keystoneRewards = keystoneRewardSlotOne .. " | " .. keystoneRewardSlotTwo .. " | " .. keystoneRewardSlotThree
    elseif keystoneTotal < 8 and keystoneTotal >= 4 then
        keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 20) + 1] .. "|r"
        keystoneRewardSlotTwo = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(4)), 20) + 1] .. "|r"
        keystoneRewards = keystoneRewardSlotOne .. " | " .. keystoneRewardSlotTwo .. " | |cFFFFCD44" .. keystoneTotal .. "/8|r"
    elseif keystoneTotal < 4 and keystoneTotal >= 1 then
        keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 20) + 1] .. "|r"
        keystoneRewards = keystoneRewardSlotOne .. " | |cFFFFCD44" .. keystoneTotal .. "/4|r | |cFFFFCD44" .. keystoneTotal .. "/8|r"
    end

    return keystoneRewards
end

function AltManager:CreateContent()

	self.main_frame.closeButton = CreateFrame("Button", "CloseButton", self.main_frame, "UIPanelCloseButton");
	self.main_frame.closeButton:ClearAllPoints()
	self.main_frame.closeButton:SetPoint("BOTTOMRIGHT", self.main_frame, "TOPRIGHT", -3, 2);
	self.main_frame.closeButton:SetScript("OnClick", function() AltManager:HideInterface(); end);

	local column_table = {
		spacer_1 = {
			order = 1,
			label = "",
			data = function(alt_data) return " " end,
		},
		name = {
			order = 1.1,
			label = constants['labels'].NAME,
			data = function(alt_data) return alt_data.name .. " (" .. (alt_data.ilevel or 0) .. ")" end,
			color = function(alt_data) return RAID_CLASS_COLORS[alt_data.class] end,
		},
		realm = {
			order = 1.2,
			data = function(alt_data) return tostring(alt_data.realmName) .. "  " end,
			remove_button = function(alt_data) return self:CreateRemoveButton(function() AltManager:RemoveCharacterByGuid(alt_data.guid) end) end
		},
		tier = {
			order = 1.3,
			label = constants['labels'].TIER_SET,
			data = function(alt_data) return (tostring(alt_data.tierBonuses) or "No Set") end,
		},
		catalyst_charges = {
			order = 1.4,
			label = constants['labels'].CATALYST_CHARGES,
			data = function(alt_data) return (alt_data.catalystCharges and tostring(alt_data.catalystCharges) or "0") end,
		},
		spacer_2 = {
			order = 2.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		mythic_title = {
			order = 2.1,
			label = constants['labels'].KEYSTONE,
			title = true,
			data = function(alt_data) return " " end,
		},
		mythic_rating = {
			order = 2.2,
			label = constants['labels'].MYTHIC_RATING,
			data = function(alt_data) return tostring(alt_data.overallDungeonScore) or 0 end,
		},
		current_keystone = {
			order = 2.3,
			label = constants['labels'].CURRENT_KEYSTONE,
			data = function(alt_data) return tostring(alt_data.keystone_details) or "None"; end,
		},
		weekly_highest = {
			order = 2.4,
			label = constants['labels'].WEEKLY_HIGHEST,
			data = function(alt_data) return tostring(alt_data.highestCompletedWeeklyKeystone) or "" end,
		},
		weekly_key_rewards = {
			order = 2.5,
			label = constants['labels'].WEEKLY_REWARDS,
			data = function(alt_data) return tostring(alt_data.completedWeeklyKeystoneRewards) or tostring("|cFFFFCD440/8|r | |cFFFFCD440/8|r | |cFFFFCD440/8|r") end,
		},
		spacer_3 = {
			order = 3.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		weekly_quests = {
			order = 3.1,
			label = constants['labels'].WEEKLY_QUESTS,
			title = true,
			data = function(alt_data) return " " end,
		},
		aiding_the_accord = {
			order = 3.2,
			label = constants['labels'].AIDING_THE_ACCORD,
			data = function(alt_data) return tostring(alt_data.accordWeeklyText) or "|cFFFF00000/3000|r" end,
		},
		sparks_of_life = {
			order = 3.3,
			label = constants['labels'].SPARKS_OF_LIFE,
			data = function(alt_data) return tostring(alt_data.sparksOfLifeText) or "|cFFFF00000/3000|r" end,
		},
		ally_loamm_niffen = {
			order = 3.4,
			label = constants['labels'].ALLY_LOAMM_NIFFEN,
			data = function(alt_data) return alt_data.allyLoammNiffen and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		ally_dream_wardens = {
			order = 3.5,
			label = constants['labels'].ALLY_DREAM_WARDENS,
			data = function(alt_data) return alt_data.allyDreamWardens and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		spacer_4 = {
			order = 4.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		weekly_events = {
			order = 4.1,
			label = constants['labels'].WEEKLY_EVENTS,
			title = true,
			data = function(alt_data) return " " end,
		},
		community_feast = {
			order = 4.2,
			label = constants['labels'].COMMUNITY_FEAST,
			data = function(alt_data) return alt_data.communityFeast and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		the_superbloom = {
			order = 4.3,
			label = constants['labels'].THE_SUPERBLOOM,
			data = function(alt_data) return alt_data.theSuperbloom and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		blooming_dreamseeds = {
			order = 4.4,
			label = constants['labels'].BLOOMING_DREAMSEEDS,
			data = function(alt_data) return alt_data.bloomingDreamseeds and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		spacer_5 = {
			order = 5.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		currencies = {
			order = 5.1,
			label = constants['labels'].CURRENCIES,
			title = true,
			data = function(alt_data) return " " end,
		},
		flightstones = {
			order = 5.2,
			label = constants['labels'].FLIGHTSTONES,
			data = function(alt_data) return (alt_data.flightstones and tostring(alt_data.flightstones) or "0") end,
		},
		whelp_fragments = {
			order = 5.3,
			label = constants['labels'].WHELPLINGS_CREST,
			data = function(alt_data) return (alt_data.whelpCrests and tostring(alt_data.whelpCrests) or "0") end,
		},
		drake_fragments = {
			order = 5.4,
			label = constants['labels'].DRAKES_CREST,
			data = function(alt_data) return (alt_data.drakeCrests and tostring(alt_data.drakeCrests) or "0") end,
		},
		wyrm_fragments = {
			order = 5.5,
			label = constants['labels'].WYRMS_CREST,
			data = function(alt_data) return (alt_data.wyrmCrests and tostring(alt_data.wyrmCrests) or "0") end,
		},
		aspect_fragments = {
			order = 5.6,
			label = constants['labels'].ASPECTS_CREST,
			data = function(alt_data) return (alt_data.aspectCrests and tostring(alt_data.aspectCrests) or "0") end,
		},
	}

	self.columns_table = column_table;

	local font_height = 14;
	local label_column = self.main_frame.label_column or CreateFrame("Button", nil, self.main_frame);
	if not self.main_frame.label_column then self.main_frame.label_column = label_column; end
	label_column:SetSize(per_alt_x, sizey);
	label_column:SetPoint("TOPLEFT", self.main_frame, "TOPLEFT", 4, -1);

	local i = 1;
	for row_iden, row in spairs(self.columns_table, function(t, a, b) return t[a].order < t[b].order end) do
		if row.label then
			if row.label~="" and not row.title then
				row.label = row.label..":"
			elseif row.label=="" then
				row.label = " ";
			end
			local label_row = self:CreateFontFrame(self.main_frame, per_alt_x, font_height, label_column, -(i-1)*font_height, row.label, "RIGHT");
			self.main_frame.lowest_point = -(i-1)*font_height;
		end
		i = i + 1
	end

end

function AltManager:HideInterface()
	self.main_frame:Hide();
end

function AltManager:ShowInterface()
	self.main_frame:Show();
	self:StoreData(self:CollectData())
	self:UpdateStrings();
end

function AltManager:CreateRemoveButton(func)
	local frame = CreateFrame("Button", nil, nil)
	frame:ClearAllPoints()
	frame:SetScript("OnClick", function() func() end);
	self:MakeRemoveTexture(frame)
	frame:SetWidth(remove_button_size)
	return frame
end

function AltManager:MakeRemoveTexture(frame)
	if frame.remove_tex == nil then
		frame.remove_tex = frame:CreateTexture(nil, "BACKGROUND")
		frame.remove_tex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		frame.remove_tex:SetAllPoints()
		frame.remove_tex:Show();
	end
	return frame
end

function AltManager:MakeTopBottomTextures(frame)
	if frame.bottomPanel == nil then
		frame.bottomPanel = frame:CreateTexture(nil);
	end
	if frame.topPanel == nil then
		frame.topPanel = CreateFrame("Frame", "AltManagerTopPanel", frame);
		frame.topPanelTex = frame.topPanel:CreateTexture(nil, "BACKGROUND");
		frame.topPanelTex:SetAllPoints();
		frame.topPanelTex:SetDrawLayer("ARTWORK", -5);
		frame.topPanelTex:SetColorTexture(0, 0, 0, 1);
		frame.topPanelString = frame.topPanel:CreateFontString("AddonName");
		frame.topPanelString:SetFont("Fonts\\FRIZQT__.TTF", 16)
		frame.topPanelString:SetTextColor(1, 1, 1, 1);
		frame.topPanelString:SetJustifyH("CENTER")
		frame.topPanelString:SetJustifyV("CENTER")
		frame.topPanelString:SetWidth(260)
		frame.topPanelString:SetHeight(20)
		frame.topPanelString:SetText("My Alt Manager");
		frame.topPanelString:ClearAllPoints();
		frame.topPanelString:SetPoint("CENTER", frame.topPanel, "CENTER", 0, 0);
		frame.topPanelString:Show();
	end
	frame.bottomPanel:SetColorTexture(0, 0, 0, 1);
	frame.bottomPanel:ClearAllPoints();
	frame.bottomPanel:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0);
	frame.bottomPanel:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 0);
	frame.bottomPanel:SetSize(frame:GetWidth(), 30);
	frame.bottomPanel:SetDrawLayer("ARTWORK", 7);
	frame.topPanel:ClearAllPoints();
	frame.topPanel:SetSize(frame:GetWidth(), 30);
	frame.topPanel:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0);
	frame.topPanel:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 0);
	frame:SetMovable(true);
	frame.topPanel:EnableMouse(true);
	frame.topPanel:RegisterForDrag("LeftButton");
	frame.topPanel:SetScript("OnDragStart", function(self,button)
		frame:SetMovable(true);
        frame:StartMoving();
    end);
	frame.topPanel:SetScript("OnDragStop", function(self,button)
        frame:StopMovingOrSizing();
		frame:SetMovable(false);
    end);
end

function AltManager:MakeBorderPart(frame, x, y, xoff, yoff, part)
	if part == nil then
		part = frame:CreateTexture(nil);
	end
	part:SetTexture(0, 0, 0, 1);
	part:ClearAllPoints();
	part:SetPoint("TOPLEFT", frame, "TOPLEFT", xoff, yoff);
	part:SetSize(x, y);
	part:SetDrawLayer("ARTWORK", 7);
	return part;
end

function AltManager:MakeBorder(frame, size)
	if size == 0 then
		return;
	end
	frame.borderTop = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, 0, frame.borderTop);
	frame.borderLeft = self:MakeBorderPart(frame, size, frame:GetHeight(), 0, 0, frame.borderLeft);
	frame.borderBottom = self:MakeBorderPart(frame, frame:GetWidth(), size, 0, -frame:GetHeight() + size, frame.borderBottom);
	frame.borderRight = self:MakeBorderPart(frame, size, frame:GetHeight(), frame:GetWidth() - size, 0, frame.borderRight);
end

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
	while not self.resetDays[date("%w",nightlyReset+offset)] do
		nightlyReset = nightlyReset + 24 * 3600
	end
	return nightlyReset
end

function AltManager:GetNextDailyResetTime()
	local resettime = GetQuestResetTime()
	if not resettime or resettime <= 0 or
		resettime > 24*3600+30 then
		return nil
	end
	if false then
		local serverHour, serverMinute = GetGameTime()
		local serverResetTime = (serverHour*3600 + serverMinute*60 + resettime) % 86400
		local diff = serverResetTime - 10800
		if math.abs(diff) > 3.5*3600
			and self:GetRegion() == "US" then
			local diffhours = math.floor((diff + 1800)/3600)
			resettime = resettime - diffhours*3600
			if resettime < -900 then
				resettime = resettime + 86400
				elseif resettime > 86400+900 then
				resettime = resettime - 86400
			end
		end
	end
	return time() + resettime
end

function AltManager:GetServerOffset()
	local serverDay = C_DateAndTime.GetCurrentCalendarTime().weekday - 1
	local localDay = tonumber(date("%w"))
	local serverHour, serverMinute = GetGameTime()
	local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
	if serverDay == (localDay + 1)%7 then
		serverHour = serverHour + 24
	elseif localDay == (serverDay + 1)%7 then
		localHour = localHour + 24
	end
	local server = serverHour + serverMinute / 60
	local localT = localHour + localMinute / 60
	local offset = floor((server - localT) * 2 + 0.5) / 2
	return offset
end

function AltManager:GetRegion()
	if not self.region then
		local reg
		reg = GetCVar("portal")
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
	local hour = tonumber(date("%H"));
	local day = C_DateAndTime.GetCurrentCalendarTime().weekday;
	return day, hour;
end

function AltManager:TimeString(length)
	if length == 0 then
		return "Now";
	end
	if length < 3600 then
		return string.format("%d mins", length / 60);
	end
	if length < 86400 then
		return string.format("%d hrs %d mins", length / 3600, (length % 3600) / 60);
	end
	return string.format("%d days %d hrs", length / 86400, (length % 86400) / 3600);
end
