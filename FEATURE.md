# FEATURES

## 1.7/photoshoot

Build into the app the ability to capture screenshots based on some commands.

Convert some of the /run commands into commands.

/run MogShareDisplayFrame:Show();MS_MogList_Button1:Click();local c=DressUpFrame.ModelScene:GetActiveCamera();c:SetYaw(2.58);c:SetZoomDistance(3.14);INEEDUIListFrame:Hide()
/run n=1;MS.SetSortFunction({value="rank"});MogShareDisplayFrame_SearchBox:SetText("October");function z()_G["MS_MogList_Button"..n]:Click();C_Timer.After(0.5,function()Screenshot();end);n=n+1;if n<16 then C_Timer.After(1,z);end;end;z()


## flag for scan

checkbox to enable  (#2 - Done)

## Meta data window on right click

* Set Name
* scanned from (user / chat)
* scan date
* rating

## secret chat post scan

