MS_SLUG, MS = ...
MS.MSG_ADDONNAME = C_AddOns.GetAddOnMetadata( MS_SLUG, "Title" )
MS.MSG_VERSION   = C_AddOns.GetAddOnMetadata( MS_SLUG, "Version" )
MS.MSG_AUTHOR    = C_AddOns.GetAddOnMetadata( MS_SLUG, "Author" )

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
	if unitExists("target") then
		print("New target:", UnitName("target"))
		for slotID = 1, 19 do
			local visualItemID = GetInventoryItemID("target", slotID)
			local actualLink   = GetInventoryItemLink("target", slotID)

			if visualItemID then
				local visualName, visualLink = GetItemInfo(visualItemID)
			end
			print( slotID, "Viaual:", visualLink or ("(uncached) itemID:"..visualItemID), "| Actual:", actualLink)
		end
	end
end



--[[



if CanInspect("target") and CheckInteractDistance("target", 1) then
    NotifyInspect("target")
end


NotifyInspect("unit") marks a unit for inspection and requests talent data from the server, and equipment info can be retrieved immediately using inventory APIs like GetInventoryItemLink. Note: since patch 3.3.5 the server can throttle requests, so events aren't guaranteed to fire every time — worth having a retry/timeout.
wowprogramming
Fandom

3. Listen for readiness

Register INSPECT_READY (fires when the unit's data becomes available) and UNIT_INVENTORY_CHANGED if you also care about gem/enchant data.

4. Pull the actual transmog data — this is the key trick

This is the part people usually get wrong. There are two different functions that look similar but return different things:

GetInventoryItemLink(unit, slot) → the real underlying item
GetInventoryItemID(unit, slot) → confirmed by the ClickMorph addon source to actually return the transmogged (visual) item, whereas GetInventoryItemLink returns the actual underlying item.
GitHub


for slotID = 1, 19 do
    local visualItemID = GetInventoryItemID("target", slotID)      -- bare numeric ID of the VISUAL item
    local actualLink    = GetInventoryItemLink("target", slotID)   -- full real link, WITH enchants/gems/bonus IDs

    if visualItemID then
        local visualName, visualLink = GetItemInfo(visualItemID)   -- convert ID -> link
        print(slotID, "Visual:", visualLink or ("(uncached) itemID:"..visualItemID), "| Actual:", actualLink)
    end
end

]]