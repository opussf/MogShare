MS_SLUG, MS = ...

-- mixin
MS.Set_mixin = {}

function MS.Set_mixin:OnRowClick(button)
	if self.link then
		if IsModifiedClick("CHATLINK") then
			-- shift-click: insert the link into the open chat edit box
			HandleModifiedItemClick(self.link)
		else
			-- plainclick
			local linkType, linkData = self.link:match("|H(%a+):(.-)|h")
			SetItemRef(linkType..":"..linkData, self.link, button)
		end
	end
    print("Row clicked:", self.Text:GetText())
    -- self is the row button itself, so self.Text / self.ActionButton work here too
end
--------

function MS.UIOnLoad( mogframe )
	DressUpFrame:HookScript("OnShow", function(self)
		print("Dressing room opened")
		MS.UIOpenFrame( mogframe )
	end)
	DressUpFrame:HookScript("OnHide", function(self)
		print("Dressing room closed")
		mogframe:Hide()
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnShow", function(self)
		print("CustomSetDetailsPanel opened.")
		MS.UIMoveFrame( mogframe )
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnHide", function(self)
		print("CustomSetDetailsPanel closed.")
		MS.UIMoveFrame( mogframe )
	end)

	mogframe:Hide()
end
function MS.UIOpenFrame( mogframe )
	print("MS.UIOpenFrame")
	MS.UI_BuildItemDisplay()
	MS.UI_ShowList()

	mogframe:Show()
end
function MS.UIMoveFrame( mogframe )
	mogframe:ClearAllPoints()

	if DressUpFrame.CustomSetDetailsPanel:IsShown() then
		mogframe:SetPoint("LEFT", DressUpFrame.CustomSetDetailsPanel, "RIGHT")
	else
		mogframe:SetPoint("LEFT", DressUpFrame, "RIGHT")
	end
end
function MS.UIMouseWheel( delta )
	print("MS.UIMouseWheel( "..delta.." )")
	MogShareDisplayFrame_MogListVSlider:SetValue(
		MogShareDisplayFrame_MogListVSlider:GetValue() - delta
	)
end

function MS.UIUpdate()
end


----

function MS.UI_BuildItemDisplay()
	if not MS.UISet_Buttons then
		local _, height = MogShareDisplayFrame_MogList:GetSize()
		local rowCount = math.floor( height / 20 )
		print(height.." high", "rows: "..rowCount)

		MS.UISet_Buttons = {}
		for rowNum = 1, rowCount do
			local buttonFrame = CreateFrame("Button", "MS_MogList_Button"..rowNum, MogShareDisplayFrame_MogList, "MSSet_template")
			buttonFrame.Text:SetText("This is row #:"..rowNum)
			buttonFrame.Text:Show()
			buttonFrame.ActionButton:SetText("PUSH ME")
			if rowNum == 1 then
				buttonFrame:SetPoint( "TOP", MogShareDisplayFrame_MogList, "TOP" )
			else
				buttonFrame:SetPoint( "TOP", "MS_MogList_Button"..rowNum-1, "BOTTOM" )
			end
			buttonFrame:Show()
			MS.UISet_Buttons[rowNum] = buttonFrame
		end
	end
end
function MS.UI_ShowList()
	print("UI_ShowList()")
	local count = 1
	local sortedItems = {}
	for k in pairs( MS_Data ) do table.insert(sortedItems, k) end
	table.sort( sortedItems )
	local offset = MogShareDisplayFrame_MogListVSlider:GetValue()

	while count <= #MS.UISet_Buttons do
		local buttonFrame = MS.UISet_Buttons[count]

		if count + offset <= #sortedItems then
			buttonFrame.link = sortedItems[count+offset]
			buttonFrame.Text:SetText(sortedItems[count+offset])
			buttonFrame.Text:Show()
			buttonFrame:Show()
		else
			buttonFrame.Text:SetText("")
			buttonFrame:Hide()
		end
		count = count + 1
	end
end


--[[

INEED_SLUG, INEED   = ...

function INEED.Sorted( t, f )
	local a = {}
	for n in pairs( t ) do table.insert( a, n ) end
	table.sort( a, f ) -- @TODO: Look into giving a sort function here.
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]   --[[
		end
	end
	return iter
end
function INEED.Fulfill_OnShow()
	INEED_FulfillFrame:RegisterEvent("BAG_UPDATE")
	INEED.Fulfill_BuildItemDisplay()
	INEED.Fulfill_ShowItems()
end
function INEED.Fulfill_OnHide()
	INEED_FulfillFrame:UnregisterEvent("BAG_UPDATE")
end
function INEED.Fulfill_ShowItems()
	local count = 1
	local sortedItems = {}
	for k in pairs( INEED.fulfillList ) do table.insert(sortedItems, k) end
	table.sort( sortedItems )

	while count <= #INEED.Fulfill_ItemFrames do
		itemID = sortedItems[count]
		local itemFrame = INEED.Fulfill_ItemFrames[count]
		local name, itemLink, icon = nil, nil, nil
		if itemID then
			name, itemLink, _, _, _, _, _, _, _, icon = GetItemInfo( itemID )
		end

		itemFrame.itemLink = itemLink
		itemFrame.itemName = name
		SetItemButtonTexture( itemFrame, icon )

		count = count + 1
	end
end
function INEED.Fulfill_BAG_UPDATE( self )
	INEED.makeFulfillList()
	INEED.Fulfill_ShowItems()
end
function INEED.Fulfill_BuildItemDisplay()
	if not INEED.Fulfill_ItemFrames then
		local width, height = INEED_FulfillFrame:GetSize()
		local rowSize = math.floor( width / 32 )
		local colSize = math.floor( (height - 50) / 32 )
		local itemFrame

		INEED.Fulfill_ItemFrames = {}

		for itemFrameNum = 1, rowSize * colSize do -- rowSize * colSize do
			itemFrame = CreateFrame( "Button", "INEED_FulfillFrameItem"..itemFrameNum, INEED_FulfillFrame, "INEEDItemTemplate" )
			local col = ((itemFrameNum - 1) % rowSize) + 1
			local row = math.floor( (itemFrameNum-1) / rowSize ) + 1

			if row == 1 then
				itemFrame:SetPoint( "TOP", INEED_FulfillFrame_Title, "BOTTOM" )
			else
				itemFrame:SetPoint( "TOP", INEED.Fulfill_ItemFrames[itemFrameNum-rowSize], "BOTTOM" )
			end
			if col == 1 then
				itemFrame:SetPoint( "LEFT", INEED_FulfillFrame, "LEFT" )
			else
				itemFrame:SetPoint( "LEFT", INEED.Fulfill_ItemFrames[itemFrameNum-1], "RIGHT" )
			end
			INEED.Fulfill_ItemFrames[itemFrameNum] = itemFrame
		end
	end
end
function INEED.Fulfill_OnMouseDown( self, useParent )
	local frameToRaise = useParent and self:GetParent() or self
	INEED.fulfillOriginalStrata = INEED.fulfillOriginalStrata or frameToRaise:GetFrameStrata()
	frameToRaise:SetFrameStrata("HIGH")
	frameToRaise:Raise()
end
function INEED.Fulfill_OnLeave(self)
	if INEED.fulfillOriginalStrata then
		self:SetFrameStrata( INEED.fulfillOriginalStrata )
	end
end


]]