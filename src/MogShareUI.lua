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
			local actor = DressUpFrame.ModelScene:GetPlayerActor()
			if actor then
				actor:Undress()
			end
			SetItemRef(linkType..":"..linkData, self.link, button)
		end
	end
	MS.SelectRow(self)
    -- print("Row clicked:", self.Text:GetText())
    -- self is the row button itself, so self.Text / self.ActionButton work here too
end
function MS.Set_mixin:OnActionButtonClick(button)
	print("Button clicked: "..self.link)
	MS_Archive[self.link] = MS_Data[self.link]
	MS_Archive[self.link].archived = time()

	MS_Data[self.link] = nil
	MS.UI_ShowList()
end
function MS.SelectRow(row)
	if MS.selectedRow and MS.selectedRow.SelectedTexture then
		MS.selectedRow.SelectedTexture:Hide()
	end
	row.SelectedTexture:Show()
	MS.selectedRow = row
end
--------

function MS.UIOnLoad( mogframe )
	DressUpFrame:HookScript("OnShow", function(self)
		-- print("Dressing room opened")
		MS.UIOpenFrame( mogframe )
	end)
	DressUpFrame:HookScript("OnHide", function(self)
		-- print("Dressing room closed")
		mogframe:Hide()
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnShow", function(self)
		-- print("CustomSetDetailsPanel opened.")
		MS.UIMoveFrame( mogframe )
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnHide", function(self)
		-- print("CustomSetDetailsPanel closed.")
		MS.UIMoveFrame( mogframe )
	end)

	mogframe:Hide()
end
function MS.UIOpenFrame( mogframe )
	-- print("MS.UIOpenFrame")
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
	-- print("MS.UIMouseWheel( "..delta.." )")
	MogShareDisplayFrame_MogListVSlider:SetValue(
		MogShareDisplayFrame_MogListVSlider:GetValue() - delta
	)
end

function MS.UIUpdate()
	MS.UI_ShowList()
end
function MS.UIOnShow()
	print("MS.UIOnShow()")
	MS.UI_BuildDropDowns()
	MS.UI_BuildItemDisplay()
	MS.UI_ShowList()
end

----
function MS.UI_BuildDropDowns()
	print("MS.UI_BuildDropDowns()")

end
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
			buttonFrame.ActionButton:SetText("Archive")
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
	-- print("UI_ShowList()")
	MS.UI_BuildItemDisplay()
	local count = 1
	local sortedItems = {}
	for k in pairs( MS_Data ) do table.insert(sortedItems, k) end
	table.sort( sortedItems, MS.sortFunctions["lastScan"])
	local offset = MogShareDisplayFrame_MogListVSlider:GetValue()

	while count <= #MS.UISet_Buttons do
		local buttonFrame = MS.UISet_Buttons[count]

		if count + offset <= #sortedItems then
			local link = sortedItems[count+offset]
			local lastScan = MS_Data[link].lastScan

			buttonFrame.link = link
			buttonFrame.Text:SetText(link.." "..date("%c", lastScan))
			buttonFrame.Text:Show()
			buttonFrame:Show()
		else
			buttonFrame.Text:SetText("")
			buttonFrame:Hide()
		end
		count = count + 1
	end
end

MS.sortFunctions = {
	lastScan = function( a, b ) -- a and b are links
		return MS_Data[a].lastScan > MS_Data[b].lastScan
	end,
}




--[[



function HS.UIInit()
	HS.TagDropDownBuild( HSConfig_TagDropDownMenu )
	HS.ModifierDropDownBuild( HSConfig_ModifierDropDownMenu )
	HS.BuildBars()
end
function HS.TagDropDownBuild( self )
	UIDropDownMenu_Initialize( self, HS.TagDropDownPopulate )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function HS.TagDropDownPopulate( self, level, menuList )
	local tagList = {}

	for hash in pairs( HS_settings.tags ) do
		table.insert( tagList, hash )
	end
	table.sort( tagList )
	for _, tag in ipairs( tagList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = tag
		info.notCheckable = true
		-- info.arg1 = tag
		info.func = HS.SetTagForEdit
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, tagList[1] )
	HS.editTag = tagList[1]
end
function HS.SetTagForEdit( info )
	-- takes the info table
	-- print( "SetTagForEdit( "..info.value.." )" )
	-- UIDropDownMenu_SetText( )
	HS.editTag = info.value
	UIDropDownMenu_SetText( HSConfig_TagDropDownMenu, info.value )
	HSConfig_TagEditBox:SetText( info.value )
	HS.UpdateUI()
end



]]
