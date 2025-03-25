-- Completed 03/24/2025
-- https://github.com/vandiel01/vC_GearStats
-------------------------------------------------------
-- Declare for this Page
-------------------------------------------------------
local vC_GS_Slot = {
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
-------------------------------------------------------
-- Simplified Gear iLevel in Character Pane
-------------------------------------------------------
function vC_GS_Display_iLevels()
	if ( InCombatLockdown() or not CharacterFrame:IsShown() ) then return end

	local overall, equipped = GetAverageItemLevel()
		CharacterStatsPane.ItemLevelFrame.Value:SetFontObject("SystemFont_Shadow_Huge1_Outline")
		CharacterStatsPane.ItemLevelFrame.Value:SetText(format("%.2f",equipped))

	local vC_Gear_Total = CharacterStatsPane:CreateFontString(nil, "ARTWORK", "SystemFont_Shadow_Med1_Outline")
		vC_Gear_Total:SetPoint("BOTTOM", CharacterStatsPane, "BOTTOM", 0, 10)
		vC_Gear_Total:SetTextColor(.71, .71, .71, .90)
		vC_Gear_Total:SetText("|cffF8C471"..format("%.3f",equipped).."|r / |cffF1948A"..format("%.3f",overall).."|r")
	local vC_Gear_Hint = CharacterStatsPane:CreateTexture(nil, "ARTWORK")
		vC_Gear_Hint:SetSize(24, 24)
		vC_Gear_Hint:SetTexture(616343)
		vC_Gear_Hint:SetPoint("LEFT", vC_Gear_Total, "RIGHT", 0, 0)
		vC_Gear_Hint:SetScript("OnEnter", function(s)
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
			GameTooltip:AddLine(
				"|cffFFFFFF"..(C_AddOns.GetAddOnMetadata("vC_GearStats", "Title"))..
				" v"..(C_AddOns.GetAddOnMetadata("vC_GearStats", "Version")).."|r\n\n"..
				"|cffF8C471Equipped|r / |cffF1948AOverall|r\n\n"..
				"Calculates Average from:\n"..
				"|cffF8C471Equipped|r: Equipped Only\n"..
				"|cffF1948AOverall|r: Equipped and in Bag\n"
			)
			GameTooltip:Show()
		end)
		vC_Gear_Hint:SetScript("OnLeave", function(s) GameTooltip:Hide() end)

	local vC_ItemLevel = "Item Level (%d+)"
	local vC_GearSeason = "(%w+) Season (%d+)"
	local vC_UpgradeLevel = "Upgrade Level: (%w+) (%d+\/%d+)"

	for a = 1, #vC_GS_Slot do    
		local slotId = GetInventorySlotInfo(vC_GS_Slot[a][1])
		local quality = GetInventoryItemQuality("player", slotId) or 0
		local itemLink = GetInventoryItemLink("player", slotId) or 0

		if ( itemLink ) then
			local vC_t = CreateFrame("GameTooltip", "vC_t"..a, nil, "GameTooltipTemplate")
				vC_t:ClearLines()
				vC_t:SetOwner(UIParent, "ANCHOR_NONE")
				vC_t:SetHyperlink(itemLink)

			local x, y, z = 0, "", nil
			for b = 2, vC_t:NumLines() do
				local s = _G["vC_t"..a.."TextLeft"..b]:GetText():gsub("|cFF808080",""):gsub("|r", "")
				if (s:find("Sell Price") or s:find("Durability") or s:find("Binds when") or s:find("Binds to")) then break end

				if ( s:find(vC_GearSeason) ) then x = tonumber(s:match("%d+")) end
				
				if ( s:find(vC_ItemLevel) ) then y = tonumber(s:match("%d+")) end
				
				if ( s:find(vC_UpgradeLevel) ) then
					z = s:match("%w+ %d+\/%d+")
					z = z:gsub("Explorer","E"):gsub("Adventurer","A"):gsub("Veteran","V"):gsub("Champion","C"):gsub("Hero","H"):gsub("Mythic","M")
				end
			end
			_G["vC_GS_iL_"..vC_GS_Slot[a][1]]:SetText("|cFF"..(x == 1 and vC_GS_Quality[1][3] or vC_GS_Quality[quality+1][3])..y.."|r")			
			_G["vC_GS_uG_"..vC_GS_Slot[a][1]]:SetText(z)
		end
	end
end
-------------------------------------------------------
-- Build Basic Frame/Label for Character Pane @ OnLoad
-------------------------------------------------------
for a = 1, #vC_GS_Slot do
	local vC_GS_SlotF = "vC_GS_"..vC_GS_Slot[a][1]
	if ( _G[vC_GS_SlotF] == nil ) then
		local vC_GS_SlotF = CreateFrame("Frame", vC_GS_SlotF, CharacterStatsPane, "BackdropTemplate")
			vC_GS_SlotF:SetSize(42,28)
			vC_GS_SlotF:SetPoint(
				(vC_GS_Slot[a][2] == 0 and "TOPLEFT" or "TOPRIGHT"),
				"Character"..vC_GS_Slot[a][1],
				(vC_GS_Slot[a][2] == 0 and "TOPRIGHT" or "TOPLEFT"),
				(vC_GS_Slot[a][2] == 0 and 8 or -8),
				((a == 15 or a == 16) and -16 or -7)
			)
			vC_GS_SlotF:SetFrameStrata("HIGH")
		local vC_GS_T = _G["vC_GS_iL_"..vC_GS_Slot[a][1]]
			vC_GS_T = vC_GS_SlotF:CreateFontString("vC_GS_iL_"..vC_GS_Slot[a][1], "ARTWORK", "GameFontNormalLargeOutline")
			vC_GS_T:SetPoint((vC_GS_Slot[a][2] == 0 and "TOPLEFT" or "TOPRIGHT"), vC_GS_SlotF)
			vC_GS_T:SetJustifyH((vC_GS_Slot[a][2] == 0 and "LEFT" or "RIGHT"))
			vC_GS_T:SetText(0)
		local vC_GS_B = _G["vC_GS_uG_"..vC_GS_Slot[a][1]]
			vC_GS_B = vC_GS_SlotF:CreateFontString("vC_GS_uG_"..vC_GS_Slot[a][1], "ARTWORK", "GameFontWhite")
			vC_GS_B:SetPoint((vC_GS_Slot[a][2] == 0 and "BOTTOMLEFT" or "BOTTOMRIGHT"), vC_GS_SlotF)
			vC_GS_B:SetJustifyH((vC_GS_Slot[a][2] == 0 and "LEFT" or "RIGHT"))
			vC_GS_B:SetText(0)
	end
end
-------------------------------------------------------
-- Armor Upgrade Level, Crest Use Order
-------------------------------------------------------
if ( vC_GS_UpgL_NxtCUpg == nil ) then
	local vC_GS_UpgL_NxtCUpg = CreateFrame("Frame", "vC_GS_UpgL_NxtCUpg", CharacterFrame, "BackdropTemplate")
		vC_GS_UpgL_NxtCUpg:SetSize(445, 40)
		vC_GS_UpgL_NxtCUpg:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", tileEdge = true, tileSize = 16,
			edgeFile = "Interface\\ToolTips\\UI-Tooltip-Border", edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		vC_GS_UpgL_NxtCUpg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 40, 38)

	local vC_GS_Nxt_Upg = vC_GS_UpgL_NxtCUpg:CreateFontString("vC_GS_Nxt_Upg", "ARTWORK", "GameFontNormalOutline")
		vC_GS_Nxt_Upg:SetPoint("LEFT", vC_GS_UpgL_NxtCUpg, "LEFT", 10, 0)
		vC_GS_Nxt_Upg:SetText(
			"|cFFFFFFFFGears|r: |cFF58D68DExplorer|r > |cFF5DADE2Adventure|r > |cFFBB8FCEVeteran|r > |cFFBB8FCEChampion|r > |cFFE59866Hero|r > |cFFE59866Mythic|r\n"..
			"|cFFFFFFFFCrest|r: |cFF58D68DWeathered|r > |cFF5DADE2Carved|r > |cFFBB8FCERuned|r > |cFFE59866Glided|r"
		)
		vC_GS_Nxt_Upg:SetJustifyH("LEFT")
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
				local GFund = (not IsGuildLeader() and " ("..GetCoinTextureString(tonumber(RemainingFund),10)..")" or "")
				DEFAULT_CHAT_FRAME:AddMessage("Auto Repair: "..GetCoinTextureString(repairCost,10)..GFund)
			end
		end
	else
		if ( canRepair and ( repairCost <= GetMoney() ) ) then
			RepairAllItems()
			DEFAULT_CHAT_FRAME:AddMessage("Auto Repair: "..GetCoinTextureString(repairCost,10))
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
	if ( e == "PLAYER_EQUIPMENT_CHANGED" ) then
		if ( CharacterFrame:IsShown() ) then vC_GS_Display_iLevels() end
	end
end)
hooksecurefunc("PaperDollFrame_UpdateStats", function()
	if ( not InCombatLockdown() ) then vC_GS_Display_iLevels() end
end)
