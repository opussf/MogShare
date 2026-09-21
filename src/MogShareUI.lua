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
	print("Archiving: "..self.link)
	MS_Archive[self.link] = MS_Data[self.link]
	MS_Archive[self.link].archived = time()

	MS_Data[self.link] = nil
	MS.UI_ShowList()
end
function MS.SelectRow(row)
	MS.selectedLink = row.link
	MS.UI_ShowList()  -- force update
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
	MS.UI_BuildDropDowns()
	MS.UI_BuildItemDisplay()
	MS.UI_ShowList()
end

----
function MS.UI_BuildDropDowns()
	MS.SortDropDownBuild( MogShareDisplayFrame_SortDropDownMenu )
end
function MS.SortDropDownBuild( self )
	UIDropDownMenu_Initialize( self, MS.SortDropDownPopulate )
	UIDropDownMenu_JustifyText( self, "LEFT" )
end
function MS.SortDropDownPopulate( self, level, menuList )
	local sortList = {}
	for sf in pairs( MS.sortFunctions ) do
		table.insert( sortList, sf )
	end
	table.sort( sortList )
	for _, sf in ipairs( sortList ) do
		info = UIDropDownMenu_CreateInfo()
		info.text = sf
		info.notCheckable = true
		info.func = MS.SetSortFunction
		UIDropDownMenu_AddButton( info, level )
	end
	UIDropDownMenu_SetText( self, MS_Options.sortBy )
end
function MS.SetSortFunction( info )
	-- takes the info table
	-- print( "SetSortFunction( "..info.value.." )" )
	MS_Options.sortBy = info.value
	UIDropDownMenu_SetText( MogShareDisplayFrame_SortDropDownMenu, info.value )
end

----------
function MS.UI_BuildItemDisplay()
	if not MS.UISet_Buttons then
		local _, height = MogShareDisplayFrame_MogList:GetSize()
		local rowCount = math.floor( height / 20 )

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
	MS.UI_BuildItemDisplay()
	local count = 1
	local sortedItems = {}
	for k in pairs( MS_Data ) do table.insert(sortedItems, k) end
	table.sort( sortedItems, MS.sortFunctions[MS_Options.sortBy].sortFun)
	local offset = floor(MogShareDisplayFrame_MogListVSlider:GetValue())
	MogShareDisplayFrame_MogListVSlider:SetMinMaxValues(0, max(0, #sortedItems - #MS.UISet_Buttons))

	while count <= #MS.UISet_Buttons do
		local buttonFrame = MS.UISet_Buttons[count]

		if count + offset <= #sortedItems then
			local link = sortedItems[count+offset]
			local lastScan = MS_Data[link].lastScan

			buttonFrame.link = link
			buttonFrame.Text:SetText(link.." "..MS.sortFunctions[MS_Options.sortBy].display(link))
			buttonFrame.Text:Show()

			if link == MS.selectedLink then
				buttonFrame.SelectedTexture:Show()
			else
				buttonFrame.SelectedTexture:Hide()
			end
			buttonFrame:Show()
		else
			buttonFrame.Text:SetText("")
			buttonFrame:Hide()
		end
		count = count + 1
	end
end

MS.sortFunctions = {
	lastScan = {
		sortFun = function( a, b ) -- a and b are links
			return MS_Data[a].lastScan > MS_Data[b].lastScan
		end,
		display = function( l ) -- l is the link
			return date("%s", MS_Data[l].lastScan)
		end,
	},
	rank = {
		sortFun = function( a, b )
			if MS_Data[a].eloData.rating ~= MS_Data[b].eloData.rating then
				return MS_Data[a].eloData.rating > MS_Data[b].eloData.rating
			end
			return MS_Data[a].lastScan > MS_Data[b].lastScan
		end,
		display = function( l )
			return MS_Data[l].eloData.rating
		end,
	},
}
