MS_SLUG, MS = ...
MS.MSG_ADDONNAME = C_AddOns.GetAddOnMetadata( MS_SLUG, "Title" )
MS.MSG_VERSION   = C_AddOns.GetAddOnMetadata( MS_SLUG, "Version" )
MS.MSG_AUTHOR    = C_AddOns.GetAddOnMetadata( MS_SLUG, "Author" )

MS_Data = {}
MS_Archive = {}
MS_Options = {}

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
			-- print("New target:", UnitName("target"))
			NotifyInspect("target")
			MogShareFrame:RegisterEvent("INSPECT_READY")
			MS.pendingGUID = UnitGUID("target")
		end
	end
end
function MS.INSPECT_READY(guid)
	if guid == MS.pendingGUID then
		local targetMogList = C_TransmogCollection.GetInspectItemTransmogInfoList()
		local mogLink = C_TransmogCollection.GetCustomSetHyperlinkFromItemTransmogInfoList(targetMogList)

		local mogData = MS_Data[mogLink] or (MS_Archive[mogLink] or {})
		mogData.archived = nil
		local ts = time()

		mogData.lastScan = ts
		mogData.playerList = mogData.playerList or {}
		local name, realm = UnitName("target")
		realm = realm or GetRealmName()
		mogData.playerList[name.."-"..realm] = ts

		mogData.classList = mogData.classList or {}
		mogData.classList[UnitClass("target")] = ts

		mogData.eloData = mogData.eloData or {
			rating      = 1500,
			comparisons = 0,
			wins        = 0,
			losses      = 0,
			lastShown   = 0,
		}

		MS_Data[mogLink] = mogData
		print(name, realm, mogLink)
		-- MS.ScanItems()

		MogShareFrame:UnregisterEvent("INSPECT_READY")
	end
end
function MS.ScanItems()
	for _, token in ipairs(MS.slotTokens) do
			local slotID = GetInventorySlotInfo(token)

			local slotAppearanceID = targetMogList[slotID].appearanceID
			local slotIllusionID = targetMogList[slotID].illusionID

			MS_Data[guid][MS.slotNames[slotID].."_appearanceID"] = slotAppearanceID
			MS_Data[guid][MS.slotNames[slotID].."_illusionID"] = slotIllusionID

			local sourceItemInfo = C_TransmogCollection.GetSourceInfo(slotAppearanceID)
			if sourceItemInfo then
				local sourceItemID = sourceItemInfo.itemID
				MS_Data[guid][MS.slotNames[slotID].."_sourceItemID"] = sourceItemID

				local item = Item:CreateFromItemID(sourceItemID)
				item:ContinueOnItemLoad(function()
					local itemName, itemLink = C_Item.GetItemInfo( sourceItemID )
					MS_Data[guid][MS.slotNames[slotID].."_sourceItemName"] = itemName
					-- print(token, slotID or "nil", MS.slotNames[slotID], itemLink)
				end)
			end
		end
end
function MS.Command(msg)
	MogShareDisplayFrame:Show()
end
