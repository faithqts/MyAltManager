local _, AltManager = ...;

_G["AltManager"] = AltManager;

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 14/10/2020
-- updates for Shadowlands by: Faith - Frostmourne, 2021-2022
-- Last edit: 28/03/2022

local sizey = 535;
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

constants.labels = {};
constants['labels'].NAME = "";
constants['labels'].WEEKLY_HIGHEST = "Weekly Highest";
constants['labels'].CURRENT_KEYSTONE = "Current Keystone";
constants['labels'].CONQUEST = "Conquest";
constants['labels'].RENOWN = "Renown";
constants['labels'].DRAGON_ISLE_SUPPLIES = "Dragon Isle Supplies";
constants['labels'].ELEMENTAL_OVERFLOW = "Elemental Overflow";
constants['labels'].STORM_SIGIL = "Storm Sigil";
constants['labels'].VALOR = "Valor";
constants['labels'].WEEKLY_QUESTS = "Weekly Quests";
constants['labels'].WEEKLY_EVENTS = "Weekly Events";
constants['labels'].RESOURCES = "Resources";
constants['labels'].AIDING_THE_ACCORD = "Aiding The Accord";
constants['labels'].CURRENT_SEASON = "Season 1";
constants['labels'].KEYSTONE = "Mythic+";
constants['labels'].MYTHIC_RATING = "Overall Rating";
constants['labels'].WEEKLY_REWARDS = "Weekly Vault";
constants['labels'].COMMUNITY_FEAST = "Community Feast";
constants['labels'].DRAGONSCALE_KEEP = "Dragonscale Keep";
constants['labels'].TRIAL_OF_FLOOD = "Trial of Flood";
constants['labels'].TRIAL_OF_ELEMENTS = "Trial of Elements";
constants['labels'].GRAND_HUNT = "The Grand Hunt";
constants['labels'].WORLD_BOSS = "World Boss";
constants['labels'].PRIMALIST_INVASIONS = "Primalist Invasions";
constants['labels'].PRIMALIST_INVASION_AIR = "Air Primalists";
constants['labels'].PRIMALIST_INVASION_EARTH = "Earth Primalists";
constants['labels'].PRIMALIST_INVASION_FIRE = "Fire Primalists";
constants['labels'].PRIMALIST_INVASION_WATER = "Water Primalists";
constants['labels'].SPARKS_OF_LIFE = "Sparks of Life"
constants['labels'].THE_STORMS_FURY = "The Storm's Fury"
constants['labels'].TIER_SET = "Tier 30"

constants.DUNGEONS = {
	[2] = "Temple",
	[165] = "Shadowmoon",
	[166] = "Grimrail",
	[169] = "Iron Docks",
	[200] = "Valor",
	[210] = "Court",
	[227] = "Kara: Lower",
	[234] = "Kara: Upper",
	[369] = "Junkyard",
	[370] = "Workshop",
	[375] = "Mists",
	[376] = "Necrotic",
	[377] = "DoS",
	[378] = "Halls",
	[379] = "Plague",
	[380] = "Sanguine",
	[381] = "Spires",
	[382] = "Theatre",
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
 };

constants.DUNGEONS_SHORT = {
	[2] = "TEMPLE",
	[165] = "SMV",
	[166] = "DEPOT",
	[169] = "DOCKS",
	[200] = "HOV",
	[210] = "COS",
	[227] = "LOWER",
	[234] = "UPPER",
	[369] = "JUNK",
	[370] = "WORK",
	[375] = "MISTS",
	[376] = "NW",
	[377] = "DOS",
	[378] = "HOA",
	[379] = "PF",
	[380] = "SD",
	[381] = "SOA",
	[382] = "TOP",
	[391] = "STRT",
	[392] = "GMBT",
	[399] = "RUBY",
	[400] = "NOKHUD",
	[401] = "AZURE",
	[402] = "ACADEMY",
	[403] = "ULDAMAN",
	[404] = "NELTHARUS",
	[405] = "BRACKEN",
	[406] = "HOI",
};

constants.VAULT_ILVL = {
	382,
	385,
	385,
	389,
	389,
	392,
	395,
	395,
	398,
	402,
	405,
	408,
	408,
	411,
	415,
	415,
	418,
	418,
	421
};

constants.TIER_SETS = {

	-- Rogue
	[200374] = true,
	[200369] = true,
	[200371] = true,
	[200372] = true,
	[200373] = true,

	-- Hunter
	[200392] = true,
	[200387] = true,
	[200389] = true,
	[200390] = true,
	[200391] = true,

	-- Evoker
	[200383] = true,
	[200378] = true,
	[200380] = true,
	[200381] = true,
	[200382] = true,

	-- Paladin
	[200419] = true,
	[200414] = true,
	[200416] = true,
	[200417] = true,
	[200418] = true,

	-- Shaman
	[200401] = true,
	[200396] = true,
	[200398] = true,
	[200399] = true,
	[200400] = true,

	-- Death Knight
	[200410] = true,
	[200405] = true,
	[200407] = true,
	[200408] = true,
	[200409] = true,

	-- Demon Hunter
	[200342] = true,
	[200347] = true,
	[200346] = true,
	[200345] = true,
	[200344] = true,

	-- Druid
	[200351] = true,
	[200353] = true,
	[200354] = true,
	[200355] = true,
	[200356] = true,

	-- Mage
	[200315] = true,
	[200317] = true,
	[200318] = true,
	[200319] = true,
	[200320] = true,

	-- Monk
	[200365] = true,
	[200360] = true,
	[200362] = true,
	[200363] = true,
	[200364] = true,

	-- Priest
	[200329] = true,
	[200326] = true,
	[200327] = true,
	[200328] = true,
	[200324] = true,

	-- Warrior
	[200423] = true,
	[200425] = true,
	[200426] = true,
	[200427] = true,
	[200428] = true,

	-- Warlock
	[200338] = true,
	[200335] = true,
	[200336] = true,
	[200337] = true,
	[200333] = true

};

constants.TIER_SLOTS = {

	[1] = "Helm",
	[3] = "Shoulders",
	[5] = "Chest",
	[7] = "Pants",
	[10] = "Gloves"

};

constants.VERSION = "10.0.5.1";

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
	main_frame:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED");

	main_frame:SetScript("OnEvent", function(self, ...)
		local event, loaded = ...;
		if event == "ADDON_LOADED" then
			if addon == loaded then
      			AltManager:OnLoad();
			end
		end
		if event == "PLAYER_LOGIN" then
        	AltManager:OnLogin();
		end
		if event == "PLAYER_LEAVING_WORLD" then
			local data = AltManager:CollectData(false);
			AltManager:StoreData(data);
		end
		if event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
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

function AltManager:PurgeDbShadowlands()
	if MyAltManagerDB == nil or MyAltManagerDB.data == nil then return end
	local remove = {}
	for alt_guid, alt_data in spairs(MyAltManagerDB.data, function(t, a, b) return t[a].ilevel > t[b].ilevel end) do
		if alt_data.charLevel == nil or alt_data.charLevel < constants.config.MIN_LEVEL then
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

	self:PurgeDbShadowlands();

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
			char_table.dragonscaleKeep = false;
			char_table.grandHunt = false;
			char_table.trialOfFlood = false;
			char_table.trialOfElements = false;
			char_table.primalistInvasionAir = false;
			char_table.primalistInvasionEarth = false;
			char_table.primalistInvasionFire = false;
			char_table.primalistInvasionWater = false;
			char_table.theStormsFury = false;
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

	if not self.addon_loaded then
		return
	end

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
	
	if UnitLevel('player') < constants.config.MIN_LEVEL then return end;

	_, i = GetAverageItemLevel()
	if i == 0 then return end;
	
	local name = UnitName('player')
	local _, class = UnitClass('player')
	local dungeon = nil;
	local expire = nil;
	local level = nil;
	local highest_mplus = 0;

	local guid = UnitGUID('player');

	local mine_old = nil
	if MyAltManagerDB and MyAltManagerDB.data then
		mine_old = MyAltManagerDB.data[guid];
	end
	
	C_MythicPlus.RequestCurrentAffixes();
	C_MythicPlus.RequestMapInfo();
	for k,v in pairs(constants.DUNGEONS) do
		C_MythicPlus.RequestMapInfo(k);
	end
	local maps = C_ChallengeMode.GetMapTable();
	for i = 1, #maps do
        C_ChallengeMode.RequestLeaders(maps[i]);
    end

	local runHistory = C_MythicPlus.GetRunHistory(false, true);
	
	local keystone_found = false;
	for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = C_Container.GetContainerNumSlots(container)
		for slot=1, slots do
			local slotItem = C_Container.GetContainerItemInfo(container, slot)
			if slotItem ~= nil then
				if slotItem.itemID == 180653 or slotItem.slotID == 151086 then
					local itemString = slotItem.hyperlink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
					local info = { strsplit(":", itemString) }
					dungeon = tonumber(info[2])
					if not dungeon then dungeon = nil end
					level = "+" .. tonumber(info[3])
					if not level then level = nil end
					expire = tonumber(info[4])
					keystone_found = true;
				end
			end
		end
	end
  
	if not keystone_found then
		dungeon = "None";
		level = ""
	end

	local worldBosses = {
		[69930] = "Basrikron",
		[69927] = "Bazual",
		[69928] = "Liskanoth",
		[69929] = "Strunraan",
	}
	local worldBoss = false
	for k,v in pairs(worldBosses)do
		if C_TaskQuest.IsActive(k) then
		end
		if C_QuestLog.IsQuestFlaggedCompleted(k) then
			worldBoss = true
		end
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

	local communityFeast = false
	if C_QuestLog.IsQuestFlaggedCompleted(70893) then
		communityFeast = true
	end

	local dragonscaleKeep = false
	if C_QuestLog.IsQuestFlaggedCompleted(70866) then
		dragonscaleKeep = true
	end

	local grandHunt = false
	if C_QuestLog.IsQuestFlaggedCompleted(70906) then
		grandHunt = true
	end

	local trialOfFlood = false
	if C_QuestLog.IsQuestFlaggedCompleted(71033) then
		trialOfFlood = true
	end

	local trialOfElements = false
	if C_QuestLog.IsQuestFlaggedCompleted(71995) then
		trialOfElements = true
	end

	local primalistInvasionAir = false
	if C_QuestLog.IsQuestFlaggedCompleted(70753) then
		primalistInvasionAir = true
	end

	local primalistInvasionFire = false
	if C_QuestLog.IsQuestFlaggedCompleted(70754) then
		primalistInvasionFire = true
	end

	local primalistInvasionEarth = false
	if C_QuestLog.IsQuestFlaggedCompleted(70723) then
		primalistInvasionEarth = true
	end

	local primalistInvasionWater = false
	if C_QuestLog.IsQuestFlaggedCompleted(70752) then
		primalistInvasionWater = true
	end

	local theStormsFury = false
	if C_QuestLog.IsQuestFlaggedCompleted(74378) then
		theStormsFury = true
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

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID);
	local maxProgress = currencyInfo.maxQuantity;
	local conquest_earned = math.min(currencyInfo.totalEarned, maxProgress);
	local conquest_total = currencyInfo.quantity;
	local conquest_spent = conquest_earned-conquest_total;
	local conquest_max = ((C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID).maxQuantity)-conquest_spent);

	local conquestPoints = "";
	if conquest_max == 0 then
		conquestPoints = string.format("%s", self:CommaValues(conquest_total));
	else 
		conquestPoints = string.format("%s / %s", self:CommaValues(conquest_total), self:CommaValues(conquest_max));
	end

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(1191);
	local maxProgress = currencyInfo.maxQuantity;
	local valor_earned = math.min(currencyInfo.totalEarned, maxProgress);
	local valor_total = currencyInfo.quantity;
	local valor_spent = valor_earned-valor_total;
	local valor_max = ((C_CurrencyInfo.GetCurrencyInfo(1191).maxQuantity)-valor_spent);

	local valorPoints = "";
	if valor_max == 0 then
		valorPoints = string.format("%s", self:CommaValues(valor_total));
	else 
		valorPoints = string.format("%s / %s", self:CommaValues(valor_total), self:CommaValues(valor_max));
	end

	local _, ilevel = GetAverageItemLevel();

	local dragonIsleSupplies = GetCurrencyAmount(2003);
	local elementalOverflow = GetCurrencyAmount(2118);
	local stormSigil = GetCurrencyAmount(2122);

	local cypherAnalysisTool = "|cFFFF0000Not Unlocked|r";
	if C_QuestLog.IsQuestFlaggedCompleted(65282) then
		cypherAnalysisTool = "|cFF00CF20Unlocked|r"
	end

	local char_table = {}

	char_table.guid = UnitGUID('player');
	char_table.name = name;
	char_table.class = class;
	char_table.ilevel = math.floor(ilevel);
	char_table.charLevel = UnitLevel('player')
	char_table.realmName = GetRealmName();
	char_table.dungeon = dungeon;
	char_table.level = level;
	char_table.runHistory = runHistory;
	char_table.highestCompletedWeeklyKeystone = self:GetHighestCompletedWeeklyKeystone();
	char_table.completedWeeklyKeystoneRewards = self:GetWeeklyKeystoneVaultRewards();
	char_table.tierBonuses = self:GetTierBonuses();
	char_table.overallDungeonScore = self:GetOverallDungeonScore();
	char_table.valorPoints = valorPoints;
	char_table.conquestPoints = self:CommaValues(conquestPoints);
	char_table.dragonIsleSupplies = self:CommaValues(dragonIsleSupplies);
	char_table.elementalOverflow = self:CommaValues(elementalOverflow);
	char_table.stormSigil = self:CommaValues(stormSigil);
	char_table.renown = renown;
	char_table.accordWeekly = accordWeekly;
	char_table.accordWeeklyText = accordWeeklyText;
	char_table.communityFeast = communityFeast;
	char_table.dragonscaleKeep = dragonscaleKeep;
	char_table.grandHunt = grandHunt;
	char_table.trialOfFlood = trialOfFlood;
	char_table.trialOfElements = trialOfElements;
	char_table.primalistInvasionAir = primalistInvasionAir;
	char_table.primalistInvasionEarth = primalistInvasionEarth;
	char_table.primalistInvasionFire = primalistInvasionFire;
	char_table.primalistInvasionWater = primalistInvasionWater;
	char_table.theStormsFury = theStormsFury;
	char_table.sparksOfLife = sparksOfLife;
	char_table.sparksOfLifeText = sparksOfLifeText;
	char_table.worldBoss = worldBoss;
	
	char_table.expires = self:GetNextWeeklyResetTime();
	char_table.dataObtained = time();
	char_table.timeUntilReset = C_DateAndTime.GetSecondsUntilDailyReset();

	return char_table;
end

function AltManager:GetTierBonuses()
	local tierText = "";
	local tierCount = 0;
	local tierItems = {};

	for k,v in pairs(constants.TIER_SLOTS) do
		if constants.TIER_SETS[GetInventoryItemID("player", k)] == true then
			tierItems[GetInventoryItemID("player", k)] = 1;
		end
	end

	for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = C_Container.GetContainerNumSlots(container)
		for slot=1, slots do
			local slotItem = C_Container.GetContainerItemInfo(container, slot)
			if slotItem ~= nil then
				if constants.TIER_SETS[slotItem.itemID] == true then
					tierItems[slotItem.itemID] = 1;
				end
			end
		end
	end

	for i,v in pairs(tierItems) do
		tierCount = tierCount + 1;
	end

	if tierCount > 0 then
		if tierCount >= 4 then
			tierCount = 4;
		end
		tierText = tierCount .. "/4 Set"
	else
		tierText = "No Set"
	end
	
	return tierText;
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
	local overallDungeonScore = C_ChallengeMode.GetOverallDungeonScore();
	local color = C_ChallengeMode.GetDungeonScoreRarityColor(overallDungeonScore);
	local colorString = "|cff";
	local r = color.r * 255;
	local g = color.g * 255;
	local b = color.b * 255;
	colorString = colorString..string.format("%2x%2x%2x", r, g, b);
	return colorString .. overallDungeonScore .. "|r";
end

function AltManager:GetHighestCompletedWeeklyKeystone()

	local level = 0;
	local dungeon = "";
	local info = C_MythicPlus.GetRunHistory(false,true);
	local keys = {};
	local dungeons = {};

	for l = 1, #info do
		level = info[l].level;
		dungeon = info[l].mapChallengeModeID;
		tinsert(keys, level)
		tinsert(dungeons, dungeon)
	end
	table.sort(keys, function(a,b) return b<a end)
	table.sort(dungeons, function(a,b) return b<a end)
	level = keys[1];
	dungeon = dungeons[1];
	if level == 0 then
		return " ";
	elseif level and level > 0 then
        local color
        if level >= 20 then
			color = "|cFFFF8000";
		elseif level >= 15 then
			color = "|cFFA335EE";
        elseif level >= 10 then
			color = "|cFF0070DD";
        elseif level >= 7 then
			color = "|cFF1EFF00";
		elseif level >= 2 then
			color = "|cFFFFFFFF";
        end
		return "+" .. level .. " " .. constants.DUNGEONS[dungeon] .. "|r";
	else
		return " ";
	end

end

function AltManager:GetLowestLevelInTopRuns(numRuns)
	local runHistory = C_MythicPlus.GetRunHistory(false, true)
	table.sort(runHistory, function(left, right) return left.level > right.level; end);
	local lowestLevel;
	local lowestCount = 0;
	for i = math.min(numRuns, #runHistory), 1, -1 do
		local run = runHistory[i];
		if not lowestLevel then
			lowestLevel = run.level;
		end
		if lowestLevel == run.level then
			lowestCount = lowestCount + 1;
		else
			break;
		end
	end
	return lowestLevel;
end

function AltManager:GetWeeklyKeystoneVaultRewards()

	local keystoneHistory = C_MythicPlus.GetRunHistory(false, true)
	local keystoneTotal = #keystoneHistory;
	local keystoneRewardSlotOne = 0;
	local keystoneRewardSlotTwo = 0;
	local keystoneRewardSlotThree = 0;
	local keystoneRewards = "|cFFFFCD440/8|r | |cFFFFCD440/8|r | |cFFFFCD440/8|r";

	if keystoneTotal >= 8 then

		keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 15)] .. "|r";
		keystoneRewardSlotTwo = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(4)), 15)] .. "|r";
		keystoneRewardSlotThree = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(keystoneTotal)), 15)] .. "|r";
		keystoneRewards = keystoneRewardSlotOne .. " | " .. keystoneRewardSlotTwo .. " | " .. keystoneRewardSlotThree;

	elseif keystoneTotal < 8 and keystoneTotal >= 4 then

		keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 15)] .. "|r";
		keystoneRewardSlotTwo = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(4)), 15)] .. "|r";
		keystoneRewards = keystoneRewardSlotOne .. " | " .. keystoneRewardSlotTwo .. " | |cFFFFCD44" .. keystoneTotal .. "/8|r";

	elseif keystoneTotal < 4 and keystoneTotal >= 1 then
		keystoneRewardSlotOne = "|cFF00CF20" .. constants.VAULT_ILVL[math.min(math.floor(AltManager:GetLowestLevelInTopRuns(1)), 15)] .. "|r";
		keystoneRewards = keystoneRewardSlotOne .. " | |cFFFFCD44" .. keystoneTotal .. "/4|r | |cFFFFCD44" .. keystoneTotal .. "/8|r";
	end

	return keystoneRewards;

end

function AltManager:CreateContent()

	self.main_frame.closeButton = CreateFrame("Button", "CloseButton", self.main_frame, "UIPanelCloseButton");
	self.main_frame.closeButton:ClearAllPoints()
	self.main_frame.closeButton:SetPoint("BOTTOMRIGHT", self.main_frame, "TOPRIGHT", -10, -2);
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
			data = function(alt_data) return tostring(alt_data.level) .. " " .. (constants.DUNGEONS[alt_data.dungeon] or alt_data.dungeon); end,
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
		current_season = {
			order = 3.1,
			label = constants['labels'].CURRENT_SEASON,
			title = true,
			data = function(alt_data) return " " end,
		},
		valor_points = {
			order = 3.2,
			label = constants['labels'].VALOR,
			data = function(alt_data) return (alt_data.valorPoints and tostring(alt_data.valorPoints) or "0") end,
		},
		conquest_points = {
			order = 3.3,
			label = constants['labels'].CONQUEST,
			data = function(alt_data) return (alt_data.conquestPoints and tostring(alt_data.conquestPoints) or "0") end,
		},
		spacer_4 = {
			order = 4.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		weekly_quests = {
			order = 4.1,
			label = constants['labels'].WEEKLY_QUESTS,
			title = true,
			data = function(alt_data) return " " end,
		},
		aiding_the_accord = {
			order = 4.2,
			label = constants['labels'].AIDING_THE_ACCORD,
			data = function(alt_data) return tostring(alt_data.accordWeeklyText) or "|cFFFF00000/3000|r" end,
		},
		sparks_of_life = {
			order = 4.3,
			label = constants['labels'].SPARKS_OF_LIFE,
			data = function(alt_data) return tostring(alt_data.sparksOfLifeText) or "|cFFFF00000/100|r" end,
		},
		the_storms_fury = {
			order = 4.4,
			label = constants['labels'].THE_STORMS_FURY,
			data = function(alt_data) return tostring(alt_data.theStormsFury) or "|cFFFF0000Incomplete|r" end,
		},
		world_boss = {
			order = 4.5,
			label = constants['labels'].WORLD_BOSS,
			data = function(alt_data) return alt_data.worldBoss and "|cFF00CF20Defeated|r" or "|cFFFF0000Alive|r" end,
		},
		spacer_5 = {
			order = 5.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		weekly_events = {
			order = 5.1,
			label = constants['labels'].WEEKLY_EVENTS,
			title = true,
			data = function(alt_data) return " " end,
		},
		community_feast = {
			order = 5.2,
			label = constants['labels'].COMMUNITY_FEAST,
			data = function(alt_data) return alt_data.communityFeast and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		dragonscale_keep = {
			order = 5.3,
			label = constants['labels'].DRAGONSCALE_KEEP,
			data = function(alt_data) return alt_data.dragonscaleKeep and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		grand_hunt = {
			order = 5.4,
			label = constants['labels'].GRAND_HUNT,
			data = function(alt_data) return alt_data.grandHunt and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		trial_of_flood = {
			order = 5.5,
			label = constants['labels'].TRIAL_OF_FLOOD,
			data = function(alt_data) return alt_data.trialOfFlood and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		trial_of_elements = {
			order = 5.6,
			label = constants['labels'].TRIAL_OF_ELEMENTS,
			data = function(alt_data) return alt_data.trialOfElements and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		spacer_6 = {
			order = 6.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		primalist_invasions = {
			order = 6.1,
			label = constants['labels'].PRIMALIST_INVASIONS,
			title = true,
			data = function(alt_data) return " " end,
		},
		primalist_invasion_air = {
			order = 6.2,
			label = constants['labels'].PRIMALIST_INVASION_AIR,
			data = function(alt_data) return alt_data.primalistInvasionAir and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		primalist_invasion_earth = {
			order = 6.2,
			label = constants['labels'].PRIMALIST_INVASION_EARTH,
			data = function(alt_data) return alt_data.primalistInvasionEarth and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		primalist_invasion_fire = {
			order = 6.2,
			label = constants['labels'].PRIMALIST_INVASION_FIRE,
			data = function(alt_data) return alt_data.primalistInvasionFire and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		primalist_invasion_water = {
			order = 6.2,
			label = constants['labels'].PRIMALIST_INVASION_WATER,
			data = function(alt_data) return alt_data.primalistInvasionWater and "|cFF00CF20Complete|r" or "|cFFFF0000Incomplete|r" end,
		},
		spacer_7 = {
			order = 7.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		resources = {
			order = 7.1,
			label = constants['labels'].RESOURCES,
			title = true,
			data = function(alt_data) return " " end,
		},
		dragon_supplies = {
			order = 7.2,
			label = constants['labels'].DRAGON_ISLE_SUPPLIES,
			data = function(alt_data) return (alt_data.dragonIsleSupplies and tostring(alt_data.dragonIsleSupplies) or "0") end,
		},
		elemental_overflow = {
			order = 7.3,
			label = constants['labels'].ELEMENTAL_OVERFLOW,
			data = function(alt_data) return (alt_data.elementalOverflow and tostring(alt_data.elementalOverflow) or "0") end,
		},
		storm_sigil = {
			order = 7.4,
			label = constants['labels'].STORM_SIGIL,
			data = function(alt_data) return (alt_data.stormSigil and tostring(alt_data.stormSigil) or "0") end,
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
		--frame.topPanelString:SetText("My Alt Manager (" .. constants.VERSION .. ")");
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
