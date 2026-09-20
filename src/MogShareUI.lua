MS_SLUG, MS = ...

function MS.UIOnLoad( mogframe )
	DressUpFrame:HookScript("OnShow", function(self)
		print("Dressing room opened")
		MS.UIOpenFrame( mogframe )
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnShow", function(self)
		print("CustomSetDetailsPanel opened.")
		MS.UIOpenFrame( mogframe )
	end)
	DressUpFrame.CustomSetDetailsPanel:HookScript("OnHide", function(self)
		print("CustomSetDetailsPanel closed.")
		MS.UIOpenFrame( mogframe )
	end)

	mogframe:Hide()
end
function MS.UIOpenFrame( mogframe )
	mogframe:ClearAllPoints()

	if DressUpFrame.CustomSetDetailsPanel:IsShown() then
		mogframe:SetPoint("LEFT", DressUpFrame.CustomSetDetailsPanel, "RIGHT")
	else
		mogframe:SetPoint("LEFT", DressUpFrame, "RIGHT")
	end
	mogframe:Show()
end

function MS.UIUpdate()
end
