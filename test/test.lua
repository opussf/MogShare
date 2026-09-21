#!/usr/bin/env lua

require "wowTest"
test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"
test.coverageReportPercent = true

DressUpFrame = CreateFrame( "GameTooltip", "DressUpFrame" )

ParseTOC( "../src/MogShare.toc" )

test.run()
