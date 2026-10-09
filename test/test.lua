#!/usr/bin/env lua

require "wowTest"
test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"
test.coverageReportPercent = true

DressUpFrame = CreateFrame( "GameTooltip", "DressUpFrame" )

ParseTOC( "../src/MogShare.toc" )

function test.before()
	chatLog = {}
	MS_Data = {}
	MS_Archive = {}
	MS.provisionalThreshold = nil
	MogShareFrame.Events.INSPECT_READY = nil
end
function test.after()
	Units["target"] = nil
end

function test.test_OnLoad_PLAYER_TARGET_CHANGED()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.PLAYER_TARGET_CHANGED )
end
function test.test_OnLoad_CHAT_MSG_GUILD()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_GUILD )
end
function test.test_OnLoad_CHAT_MSG_PARTY()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_PARTY )
end
function test.test_OnLoad_CHAT_MSG_PARTY_LEADER()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_PARTY_LEADER )
end
function test.test_OnLoad_CHAT_MSG_RAID()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_RAID )
end
function test.test_OnLoad_CHAT_MSG_RAID_LEADER()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_RAID_LEADER )
end
function test.test_OnLoad_CHAT_MSG_SAY()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_SAY )
end
function test.test_OnLoad_CHAT_MSG_WHISPER()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_WHISPER )
end
function test.test_OnLoad_CHAT_MSG_YELL()
	MS.OnLoad()
	assertTrue( MogShareFrame.Events.CHAT_MSG_YELL )
end
function test.test_PLAYER_TARGET_CHANGED_onPlayer()
	Units["target"] = Units["player"]
	Units["target"].isPlayer = true
	playerRange["target"] = 7

	MS.PLAYER_TARGET_CHANGED()

	assertTrue( MogShareFrame.Events.INSPECT_READY )
	assertEquals( "playerGUID", MS.pendingGUID )
end
function test.test_SaveLink_noCurrentLink_SavesLink()
	MS.SaveLink("[myLink]")
	assertTrue( MS_Data["[myLink]"].lastScan)
	assertTrue( MS_Data["[myLink]"].eloData)
end
function test.test_SaveLink_currentLink_LastScan_Updated()
	MS_Data["[myLink]"] = { lastScan = 5, eloData = {}}
	MS.SaveLink("[myLink]")
	assertAlmostEquals( time(), MS_Data["[myLink]"].lastScan, nil, nil, 1 )
end
function test.test_SaveLink_archivedLink_archivedCleared()
	MS_Data["[myLink]"] = { lastScan = 5, archived = 5 }
	MS.SaveLink("[myLink]")
	assertIsNil( MS_Data["[myLink]"].archived )
	assertIsNil( MS_Archive["[myLink]"] )
end
function test.test_SaveLink_archivedLink_eloDataIsIntact()
	MS_Data["[myLink]"] = { eloData = { rating = 2046 }, archived = 5 }
	MS.SaveLink("[myLink]")
	assertEquals( 2046, MS_Data["[myLink]"].eloData.rating )
end
function test.test_Prine_moves_from_Archive_to_Data()
	MS_Archive["[myLink]"] = { lastScan = 5, archived = time() - 3600 }
	MS.Prune()
	assertIsNil( MS_Archive["[myLink]"] )
	assertTrue( MS_Data["[myLink]"] )
	assertAlmostEquals( time() - 3600, MS_Data["[myLink]"].archived, nil, nil, 1 )
end
function test.test_Prune_noPrune()
	MS_Archive["[myLink]"] = { lastScan = 5, archived = time()-10 }
	MS.Prune()
	assertTrue( MS_Data["[myLink]"] )
end
function test.test_Prune_oldArchivedData()
	MS_Archive["[myLink]"] = { lastScan = 5, archived = time()-3000000 }
	MS.Prune()
	assertIsNil( MS_Data["[myLink]"] )
end
function test.test_Prune_oldArchived_MS_Data()
	MS_Data["[myLink]"] = { lastScan = 5, archived = 50 }
	MS.Prune()
	assertIsNil( MS_Data["myLink"] )
end
function test.test_CHAT_MSG_scan_validLink()
	MS.CHAT_MSG_("|c89abcdef|Hcustomset:blahblahblah|r", "Frank-Realm1" )
	assertTrue( MS_Data["|c89abcdef|Hcustomset:blahblahblah|r"] )
end
function test.test_CHAT_MSG_scan_validLink_multiple()
	MS.CHAT_MSG_("|c89abcdef|Hcustomset:blahblahblah|r  |c89abcdef|Hcustomset:blahblahblahblah|r", "Frank-Realm1" )
	assertTrue( MS_Data["|c89abcdef|Hcustomset:blahblahblah|r"] )
	assertTrue( MS_Data["|c89abcdef|Hcustomset:blahblahblahblah|r"] )
end
function test.test_CHAT_MSG_scan_invalidLink()
	MS.CHAT_MSG_( "|c89abcdef|Hitem:12345::::::::[itemLink]", "Frank-Realm1" )
	assertIsNil( MS_Data["|c89abcdef|Hitem:12345::::::::[itemLink]"] )
end
function test.test_PLAYER_ENTERING_WORLD()
	MS.PLAYER_ENTERING_WORLD()
	assertEquals( 1, MS.provisionalThreshold )
end
function test.test_INSPECT_READY()
	Units["target"] = Units["player"]
	Units["target"].isPlayer = true
	MS.pendingGUID = "playerGUID"
	MS.INSPECT_READY("playerGUID")
	assertTrue( MS_Data["|c89abcdef|Hcustomset:blahblah|r"])
end

-- MogShareELO
function test.test_ELO_GetELOProvisionalThreshold_Empty()
	assertEquals( 1, MS.GetELOProvisionalThreshold() )
end
function test.test_ELO_GetELOProvisionalThreshold_3()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	assertEquals( 3, MS.GetELOProvisionalThreshold() )
end
function test.test_ELO_GetELOProvisionalThreshold_4()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	MS.SaveLink("l3")
	assertEquals( 4, MS.GetELOProvisionalThreshold() )
end
function test.test_ELO_GetELOProvisionalThreshold_5()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	MS.SaveLink("l3")
	MS.SaveLink("l4")
	MS.SaveLink("l5")
	assertEquals( 5, MS.GetELOProvisionalThreshold() )
end
function test.test_ELO_GetELOProvisionalThreshold_6()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	MS.SaveLink("l3")
	MS.SaveLink("l4")
	MS.SaveLink("l5")
	MS.SaveLink("l6")
	assertEquals( 6, MS.GetELOProvisionalThreshold() )
end
function test.test_ELO_PickNextPair_Empty()
	local items = MS.PickNextPair()
	assertIsNil( items[1] )
	assertIsNil( items[2] )
end
function test.test_ELO_PickNextPair_One()
	MS.SaveLink("l1")
	local items = MS.PickNextPair()
	assertEquals( "l1", items[1] )
	assertIsNil( items[2] )
end
function test.test_ELO_PickNextPair_Two_notSame()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	local items = MS.PickNextPair()
	assertEquals( items[1] == "l1" and "l2" or "l1", items[2] )
end
function test.test_ELO_UpDateElo_firstWinner()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	MS.UpdateElo( "l1", "l2" )

	assertEquals( 1516, MS_Data["l1"].eloData.rating )
	assertEquals( 1484, MS_Data["l2"].eloData.rating )
end
function test.test_ELO_UpDateElo_bigUpset()
	MS.SaveLink("l1")
	MS.SaveLink("l2")
	MS_Data["l1"].eloData.rating=0
	MS_Data["l2"].eloData.rating=10000

	MS.UpdateElo( "l1", "l2" )

	assertEquals( 32, MS_Data["l1"].eloData.rating )
	assertEquals( 9968, MS_Data["l2"].eloData.rating )
end

-- MogShareUI
function test.test_Set_mixin_OnRowClick()
	-- MS.Set_mixin:OnRowClick()
end

test.run()
