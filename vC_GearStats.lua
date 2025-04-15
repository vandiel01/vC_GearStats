-- Completed 03/24/2025
-- https://github.com/vandiel01/vC_GearStats
-------------------------------------------------------
-- Declare for this Page
-------------------------------------------------------
local vC_GS_Slot = {
	-- Type, L/R Col, Future Add (Ench, Embor, Gem, Tinker)?
	{ "HeadSlot", 0, },
	{ "NeckSlot", 0, },
	{ "ShoulderSlot", 0, },
	{ "BackSlot", 0, },
	{ "ChestSlot", 0, },
	{ "WristSlot", 0, },
	{ "HandsSlot", 1, },
	{ "WaistSlot", 1, },
	{ "LegsSlot", 1, },
	{ "FeetSlot", 1, },
	{ "Finger0Slot", 1, },
	{ "Finger1Slot", 1, },
	{ "Trinket0Slot", 1, },
	{ "Trinket1Slot", 1, },
	{ "MainHandSlot", 1, },
	{ "SecondaryHandSlot", 0, },
}
local vC_GS_Quality = {
	{ 0, "Poor", "9D9D9D", },
	{ 1, "Common", "FFFFFF", },
	{ 2, "Uncommon", "1EFF00", },
	{ 3, "Rare", "0070DD", },
	{ 4, "Epic", "A335EE", },
	{ 5, "Legendary", "FF8000", },
	{ 6, "Artifact", "E6CC80", },
	{ 7, "Heirloom", "00CCFF", },
	{ 8, "WoW Token", "00CCFF", },
}
local vC_GS_TWW_CurrList = {
	{ 3008, "0070DD", "Valorstone", },
	{ 3107, "58D68D", "Weathered", },
	{ 3108, "5DADE2", "Carved", },
	{ 3109, "BB8FCE", "Runed", },
	{ 3110, "E59866", "Glided", },
}
-------------------------------------------------------
-- Simplified SetBackdrop
-------------------------------------------------------
function vC_GS_BackDrop(f, b, e, t)
	f:SetBackdrop({
		bgFile = (type(b) == "number" and b or "Interface\\" .. b), tileEdge = true, tileSize = 16,
		edgeFile = (type(e) == "number" and e or "Interface\\" .. e), edgeSize = (t ~= nil and t or 16),
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
end
-------------------------------------------------------
-- Simplified Gear iLevel in Character Pane
-------------------------------------------------------
function vC_GS_Display_iLevels()
	if ( not CharacterFrame:IsShown() ) then return end

	local overall, equipped = GetAverageItemLevel()
		CharacterStatsPane.ItemLevelFrame.Value:SetFontObject("SystemFont_Shadow_Huge1_Outline")
		CharacterStatsPane.ItemLevelFrame.Value:SetText(format("%.2f",equipped))
		
	vC_GS_Total:SetText("|cffF8C471" .. format("%.2f",equipped) .. "|r / |cffF1948A" .. format("%.2f",overall) .. "|r")	

	local vC_ItemLevel = "Item Level (%d+)"
	local vC_GearSeason = "(%w+) Season (%d+)"
	local vC_UpgradeLevel = "Upgrade Level: (%w+) (%d+\/%d+)"

	for a = 1, #vC_GS_Slot do    
		local slotId = GetInventorySlotInfo(vC_GS_Slot[a][1])
		local quality = GetInventoryItemQuality("player", slotId) or 0
		local itemLink = GetInventoryItemLink("player", slotId) or 0

		if ( itemLink ) then
			local vC_t = CreateFrame("GameTooltip", "vC_t" .. a, nil, "GameTooltipTemplate")
				vC_t:ClearLines()
				vC_t:SetOwner(UIParent, "ANCHOR_NONE")
				vC_t:SetHyperlink(itemLink)

			local x, y, z = 0, "", nil
			for b = 2, vC_t:NumLines() do
				local s = _G["vC_t" .. a .. "TextLeft" .. b]:GetText():gsub("|cFF808080",""):gsub("|r", "")
				if (s:find("Sell Price") or s:find("Durability") or s:find("Binds when") or s:find("Binds to")) then break end
				if ( s:find(vC_GearSeason) ) then x = tonumber(s:match("%d+")) end
				if ( s:find(vC_ItemLevel) ) then y = tonumber(s:match("%d+")) end
				if ( s:find(vC_UpgradeLevel) ) then
					z = s:match("%w+ %d+\/%d+")
					z = z:gsub("Explorer","E"):gsub("Adventurer","A"):gsub("Veteran","V"):gsub("Champion","C"):gsub("Hero","H"):gsub("Mythic","M")
				end
			end
			_G["vC_GS_iL_" .. vC_GS_Slot[a][1]]:SetText("|cff" .. (x == 1 and vC_GS_Quality[1][3] or vC_GS_Quality[quality+1][3]) .. y .. "|r")
			_G["vC_GS_uG_" .. vC_GS_Slot[a][1]]:SetText(z)
		end
	end
	
	
	for c = 1, #vC_GS_TWW_CurrList do
		local vC_GS_tCLn = _G["vC_GS_CNum_" .. vC_GS_TWW_CurrList[c][3]]
		vC_GS_tCLn:SetText(C_CurrencyInfo.GetCurrencyInfo(vC_GS_TWW_CurrList[c][1]).quantity)
	end
end
-------------------------------------------------------
-- Build Basic Frame/Label for Character Pane @ OnLoad
-- Armor Upgrade Level, Crest Use Order
-------------------------------------------------------
if ( vC_GS_Total == nil ) then
	local vC_GS_Total = CharacterStatsPane:CreateFontString("vC_GS_Total", "ARTWORK", "SystemFont_Shadow_Med1_Outline")
		vC_GS_Total:SetPoint("BOTTOM", CharacterStatsPane, "BOTTOM", 0, 10)
		vC_GS_Total:SetTextColor(.71, .71, .71, .90)
		vC_GS_Total:SetText("|cffF8C4710.00|r / |cffF1948A0.00|r")
			vC_Gear_Hint = CharacterStatsPane:CreateTexture(nil, "ARTWORK")
			vC_Gear_Hint:SetSize(24, 24)
			vC_Gear_Hint:SetTexture(616343)
			vC_Gear_Hint:SetPoint("LEFT", vC_GS_Total, "RIGHT", 0, 0)
			vC_Gear_Hint:SetScript("OnEnter", function(s)
				GameTooltip:ClearLines()
				GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
				GameTooltip:AddLine(
					"|cffFFFFFF" .. (C_AddOns.GetAddOnMetadata("vC_GearStats", "Title")) ..
					" v" .. (C_AddOns.GetAddOnMetadata("vC_GearStats", "Version")) .. "|r\n\n" ..
					"|cffF8C471Equipped|r / |cffF1948AOverall|r\n\n" ..
					"Calculates Average from:\n" ..
					"|cffF8C471Equipped|r: Equipped Only\n" ..
					"|cffF1948AOverall|r: Equipped and in Bag\n"
				)
				GameTooltip:Show()
			end)
			vC_Gear_Hint:SetScript("OnLeave", function(s) GameTooltip:Hide() end)

	for a = 1, #vC_GS_Slot do
		local vC_GS_SlotF = "vC_GS_" .. vC_GS_Slot[a][1]
			vC_GS_SlotF = CreateFrame("Frame", vC_GS_SlotF, CharacterStatsPane, "BackdropTemplate")
			vC_GS_SlotF:SetSize(42,28)
			vC_GS_SlotF:SetPoint(
				vC_GS_Slot[a][2] == 0 and "TOPLEFT" or "TOPRIGHT",
				"Character" .. vC_GS_Slot[a][1],
				vC_GS_Slot[a][2] == 0 and "TOPRIGHT" or "TOPLEFT",
				vC_GS_Slot[a][2] == 0 and 8 or -8,
				(a == 15 or a == 16) and -16 or -7
			)
			vC_GS_SlotF:SetFrameStrata("HIGH")
		local vC_GS_T = _G["vC_GS_iL_" .. vC_GS_Slot[a][1]]
			vC_GS_T = vC_GS_SlotF:CreateFontString("vC_GS_iL_" .. vC_GS_Slot[a][1], "ARTWORK", "GameFontNormalLargeOutline")
			vC_GS_T:SetPoint((vC_GS_Slot[a][2] == 0 and "TOPLEFT" or "TOPRIGHT"), vC_GS_SlotF)
			vC_GS_T:SetJustifyH((vC_GS_Slot[a][2] == 0 and "LEFT" or "RIGHT"))
			vC_GS_T:SetText(0)
		local vC_GS_B = _G["vC_GS_uG_" .. vC_GS_Slot[a][1]]
			vC_GS_B = vC_GS_SlotF:CreateFontString("vC_GS_uG_" .. vC_GS_Slot[a][1], "ARTWORK", "GameFontWhite")
			vC_GS_B:SetPoint((vC_GS_Slot[a][2] == 0 and "BOTTOMLEFT" or "BOTTOMRIGHT"), vC_GS_SlotF)
			vC_GS_B:SetJustifyH((vC_GS_Slot[a][2] == 0 and "LEFT" or "RIGHT"))
			vC_GS_B:SetText(0)
	end

	local vC_GS_TWW_GearUpg = CreateFrame("Frame", "vC_GS_TWW_GearUpg", CharacterFrame, "BackdropTemplate")
		vC_GS_TWW_GearUpg:SetSize(135, 110)
		vC_GS_BackDrop(vC_GS_TWW_GearUpg, 312922, 137057, 16)
		vC_GS_TWW_GearUpg:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", 0, -24)

		local RowCount = -10
		for i = 1, #vC_GS_TWW_CurrList do
			local vC_GS_CLn = "vC_GS_CNum_" .. vC_GS_TWW_CurrList[i][3]
				vC_GS_CLn = vC_GS_TWW_GearUpg:CreateFontString("vC_GS_CNum_" .. vC_GS_TWW_CurrList[i][3], "ARTWORK", "GameFontWhite")
				vC_GS_CLn:SetWidth(43)
				vC_GS_CLn:SetPoint("TOPLEFT", vC_GS_TWW_GearUpg, "TOPLEFT", 0, RowCount)
				vC_GS_CLn:SetJustifyH("RIGHT")
				vC_GS_CLn:SetText(vC_GS_TWW_CurrList[i][1] == 0 and "" or C_CurrencyInfo.GetCurrencyInfo(vC_GS_TWW_CurrList[i][1]).quantity)
			local vC_GS_CLt = "vC_GS_CTex_" .. vC_GS_TWW_CurrList[i][3]
				vC_GS_CLt = vC_GS_TWW_GearUpg:CreateFontString("vC_GS_CTex_" .. vC_GS_TWW_CurrList[i][3], "ARTWORK", "GameFontWhite")
				vC_GS_CLt:SetWidth(80)
				vC_GS_CLt:SetPoint("TOPLEFT", vC_GS_TWW_GearUpg, "TOPLEFT", 50, RowCount)
				vC_GS_CLt:SetJustifyH("LEFT")
				vC_GS_CLt:SetText("|cff" .. vC_GS_TWW_CurrList[i][2] .. vC_GS_TWW_CurrList[i][3] .. "|r")
				
			if ( i == 1 ) then
				RowCount = RowCount - 10
				local vC_GS_Sep = vC_GS_TWW_GearUpg:CreateTexture("vC_GS_Sep")
					vC_GS_Sep:SetSize(115, 2)
					vC_GS_Sep:SetTexture(130871)
					vC_GS_Sep:SetColorTexture(.8, .8, .8, .5)
					vC_GS_Sep:SetPoint("TOPLEFT", vC_GS_TWW_GearUpg, "TOPLEFT", 9, RowCount-10)
			end
			RowCount = RowCount - 16
		end

	local vC_GS_Gear_Upg_Order = CreateFrame("Frame", "vC_GS_Gear_Upg_Order", CharacterFrame, "BackdropTemplate")
		vC_GS_Gear_Upg_Order:SetSize(410, 28)
		vC_GS_BackDrop(vC_GS_Gear_Upg_Order, 312922, 137057, 16)
		vC_GS_Gear_Upg_Order:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 50, 26)
			vC_GS_Gear_Upg_Order_T = vC_GS_Gear_Upg_Order:CreateFontString(nil, "ARTWORK", "GameFontWhite")
			vC_GS_Gear_Upg_Order_T:SetPoint("LEFT", vC_GS_Gear_Upg_Order, "LEFT", 15, 0)
			vC_GS_Gear_Upg_Order_T:SetText(
				"|cff58D68DExplorer|r > |cff5DADE2Adventure|r > |cffBB8FCEVeteran|r > |cffBB8FCEChampion|r > |cffE59866Hero|r > |cffE59866Mythic|r"				
			)
end
-------------------------------------------------------
-- Auto Repair
-------------------------------------------------------
function vC_GS_Repair_Gears()
	local repairCost, canRepair = GetRepairAllCost()
	if ( IsInGuild() ) then
		if ( CanWithdrawGuildBankMoney() and CanGuildBankRepair() ) then
			if ( canRepair ) then
				RepairAllItems(true) -- Use GBank Fund
				local RemainingFund = GetGuildBankWithdrawMoney() - repairCost
				local GFund = (not IsGuildLeader() and " (" .. GetCoinTextureString(tonumber(RemainingFund),10) .. ")" or "")
				DEFAULT_CHAT_FRAME:AddMessage("Auto Repair: " .. GetCoinTextureString(repairCost) .. GFund)
			end
		else
			if ( canRepair and ( repairCost <= GetMoney() ) ) then
				RepairAllItems()
				DEFAULT_CHAT_FRAME:AddMessage("No GFund Avail, Using Your Gold Repair: " .. GetCoinTextureString(repairCost))
			end		
		end
	else
		if ( canRepair and ( repairCost <= GetMoney() ) ) then
			RepairAllItems()
			DEFAULT_CHAT_FRAME:AddMessage("Auto Repair: " .. GetCoinTextureString(repairCost))
		end
	end
end
-------------------------------------------------------
-- Register Events
-------------------------------------------------------
local vC_GS_RegEv = CreateFrame("Frame")
	vC_GS_RegEv:RegisterEvent("ADDON_LOADED")
	vC_GS_RegEv:SetScript("OnEvent", function(s, e, ...)
	if ( e == "ADDON_LOADED" ) then
		local vC_GS_Events = {
			"MERCHANT_SHOW",				-- Repair Gear
			"PLAYER_EQUIPMENT_CHANGED",		-- Detect Equip Change?
		}
		for i = 1, #vC_GS_Events do
			vC_GS_RegEv:RegisterEvent(vC_GS_Events[i])
		end
		vC_GS_RegEv:UnregisterEvent("ADDON_LOADED")
	end
	-- Repair Gear
	if ( e == "MERCHANT_SHOW" ) then vC_GS_Repair_Gears() end
	-- Equip Change Events
	if ( e == "PLAYER_EQUIPMENT_CHANGED" and CharacterFrame:IsShown() ) then
		vC_GS_Display_iLevels()
	end
end)
hooksecurefunc("PaperDollFrame_UpdateStats", function()
	if ( CharacterFrame:IsShown() ) then vC_GS_Display_iLevels() end
end)
