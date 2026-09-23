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
function test.notest_PLAYER_TARGET_CHANGED_onPlayer()
	Units["target"] = Units["player"]
	Units["target"].isPlayer = true

	-- test.dump(UnitExists("target"))
	-- test.dump(UnitIsPlayer("target"))
	assertTrue( UnitIsPlayer("target") )
	test.dump(Units)
	fail()
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
	MS_Archive["[myLink]"] = { lastScan = 5, archived = 5 }
	MS.SaveLink("[myLink]")
	assertIsNil( MS_Data["[myLink]"].archived )
	assertIsNil( MS_Archive["[myLink]"] )
end
function test.test_SaveLink_archivedLink_eloDataIsIntact()
	MS_Archive["[myLink]"] = { eloData = { rating = 2046 } }
	MS.SaveLink("[myLink]")
	assertEquals( 2046, MS_Data["[myLink]"].eloData.rating )
end
function test.test_Prune_noPrune()
	MS_Archive["[myLink]"] = { lastScan = 5, archived = time()-10 }
	MS.Prune()
	assertTrue( MS_Archive["[myLink]"] )
end
function test.test_Prune_oldArchivedData()
	MS_Archive["[myLink]"] = { lastScan = 5, archived = time()-3000000 }
	MS.Prune()
	assertIsNil( MS_Archive["[myLink]"] )
end


test.run()
