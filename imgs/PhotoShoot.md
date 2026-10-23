# Photo Shoot

Use Goldchal

1 Class - Rogue - Blue Kilt  - class search

2 Rank - poptar - Jungle Hat - guild search

3 Rank - wins>9 - Midnight Sarong
4 Rank - losses>8 - Cowl
5 Rank - rank<1400

6 Rank - forever - Jerkin - item search

7 Name - search by name

8 Scan - search by month
9 Scan - search by monthyear

10 Archived ?



/run tr={{"class","rogue",1},{"rank","poptar",1},{"rank","wins>9",1},{"rank","losses>8",1}};ti=nil
/run tr={{"rank","September",1},{"rank","September",2},{"rank","September",3},{"rank","September",4},{"rank","September",5},{"rank","September",6},{"rank","September",7},{"rank","September",8},{"rank","September",9},{"rank","September",10}};ti=nil



/run ti=(ti or 0)+1;MogShareDisplayFrame:Show();MS.SetSortFunction({value=tr[ti][1]});MogShareDisplayFrame_SearchBox:SetText(tr[ti][2]);_G["MS_MogList_Button"..tr[ti][3]]:Click();INEEDUIListFrame:Hide();Screenshot()




/isnext -. Igotha Bankept
/run MogShareDisplayFrame:Show();MS_MogList_Button1:Click();local c=DressUpFrame.ModelScene:GetActiveCamera();c:SetYaw(2.58);c:SetZoomDistance(3.14);INEEDUIListFrame:Hide()
/run n=1;MS.SetSortFunction({value="rank"});MogShareDisplayFrame_SearchBox:SetText("October");function z()_G["MS_MogList_Button"..n]:Click();C_Timer.After(0.5,function()Screenshot();end);n=n+1;if n<16 then C_Timer.After(1,z);end;end;z()








function MS.SetSortFunction( info )
	-- takes the info table
	MS_Options.sortBy = info.value




	/run AcceptGroup()

	AcceptGroupInvite() -- nil?


https://github.com/awk-bb/AutoAccept/blob/master/AutoAccept.lua

