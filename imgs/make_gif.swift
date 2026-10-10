#!/usr/bin/env swift
//
// make_gif.swift: stitch image files into an animated GIF using ImageIO.
//
// Usage:
//   swift make_gif.swift <output.gif> <delay-seconds> <frame1> <frame2> ...
//
// Example:
//   swift make_gif.swift out.gif 0.2 frame*.png
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

let args = CommandLine.arguments
guard args.count >= 4, let delay = Double(args[2]), delay > 0 else {
    fail("Usage: swift make_gif.swift <output.gif> <delay-seconds> <frame1> <frame2> ...")
}

let outputURL = URL(fileURLWithPath: args[1])
let inputPaths = Array(args[3...])

guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.gif.identifier as CFString,
    inputPaths.count,
    nil
) else {
    fail("Could not create GIF destination at \(outputURL.path)")
}

// File-level properties: loop count 0 = loop forever.
let fileProperties: [String: Any] = [
    kCGImagePropertyGIFDictionary as String: [
        kCGImagePropertyGIFLoopCount as String: 0
    ]
]
CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)

// Per-frame properties: how long each frame is shown, in seconds.
let frameProperties: [String: Any] = [
    kCGImagePropertyGIFDictionary as String: [
        kCGImagePropertyGIFDelayTime as String: delay
    ]
]

var added = 0
for path in inputPaths {
    let url = URL(fileURLWithPath: path)
    guard
        let source = CGImageSourceCreateWithURL(url as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
    else {
        FileHandle.standardError.write(Data("Skipping unreadable image: \(path)\n".utf8))
        continue
    }
    CGImageDestinationAddImage(destination, image, frameProperties as CFDictionary)
    added += 1
}

guard added > 0 else {
    fail("No readable frames were found.")
}

guard CGImageDestinationFinalize(destination) else {
    fail("Failed to write \(outputURL.path)")
}

print("Wrote \(outputURL.path) with \(added) frame(s), \(delay)s per frame.")