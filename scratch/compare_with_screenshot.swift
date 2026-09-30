import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let testUrl = URL(fileURLWithPath: "scratch/whole_test_result.png")

guard let shotImg = NSImage(contentsOf: shotUrl),
      let testImg = NSImage(contentsOf: testUrl) else {
    print("Error loading images")
    exit(1)
}

let shotRep = NSBitmapImageRep(data: shotImg.tiffRepresentation!)!
let testRep = NSBitmapImageRep(data: testImg.tiffRepresentation!)!

print("Shot size: \(shotRep.pixelsWide) x \(shotRep.pixelsHigh)")
print("Test size: \(testRep.pixelsWide) x \(testRep.pixelsHigh)")

// In Screenshot (274 x 469), character is at x: 42..179 (w: 138), y: 25..450 (h: 426).
// In Test (220 x 681), character is the full image (h: 681).
// Let's create a side-by-side image with normalized height:
// Scale shot so character height matches test (scale = 681 / 426 = 1.59859)
let scale = 681.0 / 426.0
let shotCharCropX = 42.0 * scale
let shotCharCropY = 25.0 * scale
let scaledShotW = Double(shotRep.pixelsWide) * scale
let scaledShotH = Double(shotRep.pixelsHigh) * scale

let outW = 220.0 * 2.0 + 40.0
let outH = 681.0

let canvas = NSImage(size: NSSize(width: outW, height: outH))
canvas.lockFocus()

// Fill background dark gray
NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: outW, height: outH).fill()

// Draw Shot (left side, cropped to character)
// Cocoa y is inverted.
// In shot, character top is at y=25 from top, character bottom is at y=450 from top.
// In cocoa coords for scaled shot:
// character top is at scaledShotH - 25*scale
// character bottom is at scaledShotH - 450*scale
// We want character bottom at cocoa y = 0 (or aligned with test bottom)
// In test (220x681), character bottom is at cocoa y = 0, top at cocoa y = 681.
let shotDrawX = 20.0 - 42.0 * scale
let shotDrawY = 0.0 - (scaledShotH - 450.0 * scale)

shotImg.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: scaledShotW, height: scaledShotH),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

// Draw Test (right side)
testImg.draw(in: NSRect(x: 240.0, y: 0, width: 220.0, height: 681.0),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/side_by_side_comparison.png"))
print("Saved scratch/side_by_side_comparison.png")
