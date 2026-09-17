#!/usr/bin/env lua

require "wowTest"
test.outFileName = "testOut.xml"
test.coberturaFileName = "../coverage.xml"
test.coverageReportPercent = true

ParseTOC( "../src/MogShare.toc" )

test.run()
