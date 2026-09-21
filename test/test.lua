#!/usr/bin/env lua

require "wowTest"
test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"
test.coverageReportPercent = true

DressUpFrame = CreateFrame( "GameTooltip", "DressUpFrame" )

ParseTOC( "../src/MogShare.toc" )

function test.before()
    chatLog = {}
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

test.run()
