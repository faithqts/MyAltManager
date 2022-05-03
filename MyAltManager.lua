local _, AltManager = ...;

_G["AltManager"] = AltManager;

-- Made by: Qooning - Tarren Mill, 2017-2020
-- Previously Method Alt Manager
-- updates for Bfa by: Kabootzey - Tarren Mill <Ended Careers>, 2018
-- Last edit: 14/10/2020
-- updates for Shadowlands by: Faith - Frostmourne, 2021-2022
-- Last edit: 28/03/2022

local sizey = 485;
local xoffset = 0;
local yoffset = 50;
local addon = "MyAltManager";
local numel = table.getn;

local per_alt_x = 170;
local ilvl_text_size = 18;
local remove_button_size = 22;
local min_x_size = 300;

local constants = {};

constants.config = {};
constants['config'].MIN_LEVEL = 60;

constants.labels = {};
constants['labels'].NAME = "";
constants['labels'].WEEKLY_HIGHEST = "Weekly Highest";
constants['labels'].CURRENT_KEYSTONE = "Current Keystone";
constants['labels'].CONQUEST = "Conquest";
constants['labels'].RENOWN = "Renown";
constants['labels'].SOUL_ASH = "Soul Ash";
constants['labels'].SOUL_CINDERS = "Soul Cinders";
constants['labels'].COSMIC_FLUX = "Cosmic Flux";
constants['labels'].CYPHERS = "Cyphers";
constants['labels'].STORED_ANIMA = "Stored Anima";
constants['labels'].VALOR = "Valor";
constants['labels'].WEEKLY_QUESTS = "Weekly Quests";
constants['labels'].RESOURCES = "Resources";
constants['labels'].PATTERNS_WITHIN_PATTERNS = "Patterns Within Patterns";
constants['labels'].A_NEW_DEAL = "A New Deal (PVP)";
constants['labels'].REPLENISH_THE_RESERVOIR = "Anima Reservoir";
constants['labels'].CURRENT_SEASON = "Season 3";
constants['labels'].KEYSTONE = "Mythic+";
constants['labels'].MYTHIC_RATING = "Overall Rating";
constants['labels'].WEEKLY_REWARDS = "Weekly Vault"
constants['labels'].CYPHER_ANALYSIS_TOOL = "Increased Cyphers (+50%)"

constants.DUNGEONS = {
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
 };

constants.DUNGEONS_SHORT = {
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
};

constants.COVENANTS = {
	[0] = "|T3752121:16:16:0:0:64:64:4:60:4:60|t";
	[1] = "|T3257748:16:16:0:0:64:64:4:60:4:60|t";
	[2] = "|T3257751:16:16:0:0:64:64:4:60:4:60|t";
	[3] = "|T3257750:16:16:0:0:64:64:4:60:4:60|t";
	[4] = "|T3257749:16:16:0:0:64:64:4:60:4:60|t";
};

constants.COVENANTS_NAME = {
	[0] = "None";
	[1] = "Kyrian";
	[2] = "Venthyr";
	[3] = "Night Fae";
	[4] = "Necro";
};

constants.VAULT_ILVL = {
	233,
	235,
	239,
	242,
	246,
	249,
	252,
	256,
	259,
	262,
	265,
	268,
	272,
	275,
	278
};

constants.TIER_SETS = {

	-- Rogue
	[188901] = true,
	[188902] = true,
	[188903] = true,
	[188905] = true,
	[188907] = true,

	-- Hunter
	[188861] = true,
	[188860] = true,
	[188859] = true,
	[188858] = true,
	[188856] = true,

	-- Paladin
	[188933] = true,
	[188932] = true,
	[188931] = true,
	[188929] = true,
	[188928] = true,

	-- Shaman
	[188925] = true,
	[188924] = true,
	[188923] = true,
	[188922] = true,
	[188920] = true,

	-- Death Knight
	[188868] = true,
	[188867] = true,
	[188866] = true,
	[188864] = true,
	[188863] = true,

	-- Demon Hunter
	[188898] = true,
	[188896] = true,
	[188894] = true,
	[188893] = true,
	[188892] = true,

	-- Druid
	[188853] = true,
	[188851] = true,
	[188849] = true,
	[188848] = true,
	[188847] = true,

	-- Mage
	[188845] = true,
	[188844] = true,
	[188843] = true,
	[188842] = true,
	[188839] = true,

	-- Monk
	[188916] = true,
	[188914] = true,
	[188912] = true,
	[188911] = true,
	[188910] = true,

	-- Priest
	[188881] = true,
	[188880] = true,
	[188879] = true,
	[188878] = true,
	[188875] = true,

	-- Warrior
	[188942] = true,
	[188941] = true,
	[188940] = true,
	[188938] = true,
	[188937] = true,

	-- Warlock
	[188890] = true,
	[188889] = true,
	[188888] = true,
	[188887] = true,
	[188884] = true

};

constants.TIER_SLOTS = {

	[1] = "Helm",
	[3] = "Shoulders",
	[5] = "Chest",
	[7] = "Pants",
	[10] = "Gloves"

};

constants.VERSION = "9.2.0.5";

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
	f:GetFontString():SetHeight(20)
	
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
			char_table.patterns = false;
			char_table.replenishTheReservoir = false;
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
		local slots = GetContainerNumSlots(container)
		for slot=1, slots do
			local _, _, _, _, _, _, slotLink, _, _, slotItemID = GetContainerItemInfo(container, slot)
			if slotItemID == 180653 or slotItemID == 151086 then
				local itemString = slotLink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
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
  
	if not keystone_found then
		dungeon = "None";
		level = ""
	end

	local replenishTheReservoirs = {
		[61984] = "Fae",
		[61981] = "Venthyr",
		[61982] = "Kyrian",
		[61983] = "Necro",
	}
	local replenishTheReservoir = false
	for k,v in pairs(replenishTheReservoirs) do
		if C_QuestLog.IsQuestFlaggedCompleted(k) then
			replenishTheReservoir = v
		end
	end

	local patterns = false
	local patternsText = false
	if C_QuestLog.IsOnQuest(66042) then
		local percent = GetQuestProgressBarPercent(66042);
		patternsText = "|cFFFBD910" .. percent .. "%|r";
	elseif C_QuestLog.IsQuestFlaggedCompleted(66042) then
		patternsText = "|cFF00CF20Complete|r"
		patterns = true
	else
		patternsText = "|cFFFF0000Not Started|r";
	end

	local aNewDeal = false
	local aNewDealText = false
	if C_QuestLog.IsOnQuest(65649) then
		local questInfo = C_QuestLog.GetQuestObjectives(65649);
		local progress = questInfo[1].numFulfilled;
		aNewDealText = "|cFFFBD910" .. progress .. "/150|r";
	elseif C_QuestLog.IsQuestFlaggedCompleted(65649) then
		aNewDealText = "|cFF00CF20Complete|r"
		aNewDeal = true
	else
		aNewDealText = "|cFFFF0000Not Started|r";
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

	local soulAsh = GetCurrencyAmount(1828);
	local soulCinders = GetCurrencyAmount(1906);
	local cosmicFlux = GetCurrencyAmount(2009);
	local cyphers = GetCurrencyAmount(1979);
	local storedAnima = GetCurrencyAmount(1813);
	local renown = C_CovenantSanctumUI.GetRenownLevel();

	local cypherAnalysisTool = "|cFFFF0000Not Unlocked|r";
	if C_QuestLog.IsQuestFlaggedCompleted(65282) then
		cypherAnalysisTool = "|cFF00CF20Unlocked|r"
	end

	local char_table = {}

	char_table.guid = UnitGUID('player');
	char_table.name = name;
	char_table.class = class;
	char_table.ilevel = math.floor(ilevel);
	char_table.covenant = self:GetActiveCovenant();
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
	char_table.soulAsh = self:CommaValues(soulAsh);
	char_table.soulCinders = self:CommaValues(soulCinders);
	char_table.cosmicFlux = self:CommaValues(cosmicFlux);
	char_table.cyphers = self:CommaValues(cyphers);
	char_table.storedAnima = self:CommaValues(storedAnima);
	char_table.renown = renown;
	char_table.patterns = patterns;
	char_table.patternsText = patternsText;
	char_table.aNewDeal = aNewDeal;
	char_table.aNewDealText = aNewDealText;
	char_table.replenishTheReservoir = replenishTheReservoir;
	char_table.cypherAnalysisTool = cypherAnalysisTool;
	
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
		local slots = GetContainerNumSlots(container)
		for slot=1, slots do
			local _, _, _, _, _, _, _, _, _, slotItemID = GetContainerItemInfo(container, slot)
			if constants.TIER_SETS[slotItemID] == true then
				tierItems[slotItemID] = 1;
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
		tierText = "Tier (" .. tierCount .. "/4)"
	else
		tierText = "Tier (0/4)"
	end
	
	return tierText;
end

function AltManager:UpdateStrings()
	local font_height = 18;
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

function AltManager:GetActiveCovenant()

	local currentCovenantId = C_Covenants.GetActiveCovenantID();
	return constants.COVENANTS_NAME[currentCovenantId];

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
		renown_tier = {
			order = 1.3,
			label = " ",
			title = true,
			data = function(alt_data) return (tostring(alt_data.covenant .. " (" .. alt_data.renown) .. ")" or "") .. ", " .. (tostring(alt_data.tierBonuses) or "Tier (0/4)") end,
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
		patterns = {
			order = 4.2,
			label = constants['labels'].PATTERNS_WITHIN_PATTERNS,
			data = function(alt_data) return tostring(alt_data.patternsText) or "|cFFFF00000%|r" end,
		},
		a_new_deal = {
			order = 4.3,
			label = constants['labels'].A_NEW_DEAL,
			data = function(alt_data) return tostring(alt_data.aNewDealText) or "|cFFFF00000/150|r" end,
		},
		increased_cyphers = {
			order = 4.4,
			label = constants['labels'].CYPHER_ANALYSIS_TOOL,
			data = function(alt_data) return tostring(alt_data.cypherAnalysisTool) or "|cFFFF0000Not Unlocked|r" end,
		},
		spacer_5 = {
			order = 5.0,
			label = "",
			data = function(alt_data) return " " end,
		},
		resources = {
			order = 5.1,
			label = constants['labels'].RESOURCES,
			title = true,
			data = function(alt_data) return " " end,
		},
		stored_anima = {
			order = 5.2,
			label = constants['labels'].STORED_ANIMA,
			data = function(alt_data) return tostring(alt_data.storedAnima) or "0" end,
		},
		soul_ash = {
			order = 5.3,
			label = constants['labels'].SOUL_ASH,
			data = function(alt_data) return tostring(alt_data.soulAsh) or "0" end,
		},
		soul_cinders = {
			order = 5.4,
			label = constants['labels'].SOUL_CINDERS,
			data = function(alt_data) return tostring(alt_data.soulCinders) or "0" end,
		},
		cosmic_flux = {
			order = 5.5,
			label = constants['labels'].COSMIC_FLUX,
			data = function(alt_data) return tostring(alt_data.cosmicFlux) or "0" end,
		},
		cyphers = {
			order = 5.6,
			label = constants['labels'].CYPHERS,
			data = function(alt_data) return tostring(alt_data.cyphers) or "0" end,
		},
	}

	self.columns_table = column_table;

	local font_height = 18;
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
		frame.topPanelString:SetFont("Fonts\\FRIZQT__.TTF", 20)
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
