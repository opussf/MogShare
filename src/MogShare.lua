MS_SLUG, MS = ...
MS.MSG_ADDONNAME = C_AddOns.GetAddOnMetadata( MS_SLUG, "Title" )
MS.MSG_VERSION   = C_AddOns.GetAddOnMetadata( MS_SLUG, "Version" )
MS.MSG_AUTHOR    = C_AddOns.GetAddOnMetadata( MS_SLUG, "Author" )

MS_Data = {}

MS.slotTokens = {
	"HeadSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot", "LegsSlot",
	"FeetSlot", "WristSlot", "HandsSlot", "BackSlot", "MainHandSlot",
	"SecondaryHandSlot", "TabardSlot"
}
MS.slotNames = {}
MS.slotNames = {
	[1]  = "Head",
	[2]  = "Neck",
	[3]  = "Shoulder",
	[4]  = "Shirt",
	[5]  = "Chest",
	[6]  = "Waist",
	[7]  = "Legs",
	[8]  = "Feet",
	[9]  = "Wrist",
	[10] = "Hands",
	[11] = "Finger 1",
	[12] = "Finger 2",
	[13] = "Trinket 1",
	[14] = "Trinket 2",
	[15] = "Back",
	[16] = "Main Hand",
	[17] = "Off Hand",
	[18] = "Ranged",     -- relic/ranged slot; unused on many classes/expansions
	[19] = "Tabard",
}

if not MogScanTooltip then
	CreateFrame("GameTooltip", "MogScanTooltip", UIParent, "GameTooltipTemplate")
end

function MS.OnLoad()
	SLASH_MS1 = "/MS"
	SlashCmdList["MS"] = function(msg) MS.Command(msg); end
	-- MogShareFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MogShareFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- MogShareFrame:RegisterEvent("CHAT_MSG_PARTY")
	-- MogShareFrame:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	-- MogShareFrame:RegisterEvent("CHAT_MSG_ADDON")

end
function MS.PLAYER_TARGET_CHANGED()
	-- I still prefer positive checks
	if UnitExists("target") and UnitIsPlayer("target") then
		if CanInspect("target") and CheckInteractDistance("target",1) then
			print("New target:", UnitName("target"))
			NotifyInspect("target")
			MogShareFrame:RegisterEvent("INSPECT_READY")
			MS.pendingGUID = UnitGUID("target")
		end
	end
end
function MS.INSPECT_READY(guid)
	if guid == MS.pendingGUID then
		MS_Data[guid] = MS_Data[guid] or {}
		MS_Data[guid].name, MS_Data[guid].realm = UnitName("target")

		local targetMogList = C_TransmogCollection.GetInspectItemTransmogInfoList()
		-- MS_Data[guid].mogList = targetMogList

		for _, token in ipairs(MS.slotTokens) do
			local slotID = GetInventorySlotInfo(token)

			local slotAppearanceID = targetMogList[slotID].appearanceID

			MS_Data[guid][MS.slotNames[slotID].."_appearanceID"] = slotAppearanceID

			local sourceItemInfo = C_TransmogCollection.GetSourceInfo(slotAppearanceID)
			if sourceItemInfo then
				local sourceItemID = sourceItemInfo.itemID
				MS_Data[guid][MS.slotNames[slotID].."_sourceItemID"] = sourceItemID

				local itemName, itemLink = C_Item.GetItemInfo( sourceItemID )
				MS_Data[guid][MS.slotNames[slotID].."_sourceItemName"] = itemName

				print(token, slotID or "nil", MS.slotNames[slotID], itemLink)
			end

			-- local visualItemID = GetInventoryItemID("target", slotID)
			-- -- local actualLink   = GetInventoryItemLink("target", slotID)
			-- print(token, slotID or "nil", MS.slotNames[slotID], visualItemID or "nil")

			-- if visualItemID then
			-- 	-- local visualName, visualLink = GetItemInfo(visualItemID)
			-- 	MS_Data[guid][MS.slotNames[slotID]] = visualItemID
			-- 	local appearanceID, modifiedAppearanceID = C_TransmogCollection.GetItemInfo(visualItemID)
			-- 	print(token, slotID or "nil", MS.slotNames[slotID], visualItemID or "nil",
			-- 			appearanceID or "no appearanceID", modifiedAppearanceID or "no modifiedAppearanceID")
			-- 	if appearanceID then
			-- 		MS_Data[guid][MS.slotNames[slotID].."_appearanceID"] = appearanceID
			-- 		MS_Data[guid][MS.slotNames[slotID].."_appearanceInfo"] = C_TransmogCollection.GetAppearanceSourceInfo(appearanceID)
			-- 		-- print(MS_Data[guid][MS.slotNames[slotID].."_appearanceInfo"].transmoglink or "nil",
			-- 				-- MS_Data[guid][MS.slotNames[slotID].."_appearanceInfo"].itemlink or "nil")


			-- 	-- MS_Data[guid][MS.slotNames[slotID].."_modifiedAppearanceID"] = modifiedAppearanceID
			-- 	-- MS_Data[guid][MS.slotNames[slotID].."_modifiedAppearanceInfo"] = C_TransmogCollection.GetAppearanceSourceInfo(modifiedAppearanceID)
			-- 	-- print(MS_Data[guid][MS.slotNames[slotID].."_modifiedAppearanceInfo"].transmoglink)

			-- 	-- MS_Data[guid][MS.slotNames[slotID].."_sourceItemID"] = C_TransmogCollection.GetSourceItemID(modifiedAppearanceID)
			-- 	-- print(MS_Data[guid][MS.slotNames[slotID].."_sourceItemID"])

			-- 		MS_Data[guid][MS.slotNames[slotID].."_appearanceSources"] = C_TransmogCollection.GetAllAppearanceSources(appearanceID, slotID)
			-- 		for _, appearanceSourceID in ipairs(MS_Data[guid][MS.slotNames[slotID].."_appearanceSources"]) do
			-- 			MS_Data[guid][MS.slotNames[slotID].."_appearanceSources"][appearanceSourceID] = C_TransmogCollection.GetAppearanceSourceInfo(appearanceSourceID)
			-- 		end


			-- 		-- MS_Data[guid][MS.slotNames[slotID].."_sourceInfo"] = C_TransmogCollection.GetSourceInfo(MS_Data[guid][MS.slotNames[slotID].."_sourceItemID"])
			-- 	end

				-- MS_Data[guid][MS.slotNames[slotID].."_AppliedItemTransmogInfo"] = C_Item.GetAppliedItemTransmogInfo(slotID)



				-- --
				-- MogScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
				-- MogScanTooltip:ClearLines()
				-- MogScanTooltip:SetInventoryItem("target", slotID)

				-- MS_Data[guid][MS.slotNames[slotID].."_tooltip"] = MogScanTooltip


				-- local tt = C_TooltipInfo.GetItemByItemModifiedAppearanceID

				-- print(C_TooltipInfo.GetItemByItemModifiedAppearanceID(MogScanTooltip))


			-- end
		end
		MogShareFrame:UnregisterEvent("INSPECT_READY")
	end
end
