import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let testUrl = URL(fileURLWithPath: "scratch/test_shift_dx12_dy0.png")

let imgShot = NSImage(contentsOf: shotUrl)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!
let imgTest = NSImage(contentsOf: testUrl)!
let repTest = NSBitmapImageRep(data: imgTest.tiffRepresentation!)!

// Zoom head and neck:
// In Test (220x681): x: 30..180, y: 10..180 (w: 150, h: 170)
// In Shot: scale = 426 / 681.
// x in shot: 43 + x_test * (136/220)
// y in shot: 25 + y_test * (426/681)

let zoomW = 300.0
let zoomH = 340.0

let canvas = NSImage(size: NSSize(width: zoomW * 2.0 + 20.0, height: zoomH))
canvas.lockFocus()

NSColor(calibratedWhite: 0.1, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: zoomW * 2.0 + 20.0, height: zoomH).fill()

// Draw cropped shot (left)
let shotCropX = 43.0 + 30.0 * (136.0 / 220.0)
let shotCropY = 25.0 + 10.0 * (426.0 / 681.0)
let shotCropW = 150.0 * (136.0 / 220.0)
let shotCropH = 170.0 * (426.0 / 681.0)

let cocoaShotCropY = Double(repShot.pixelsHigh) - shotCropY - shotCropH
imgShot.draw(in: NSRect(x: 0, y: 0, width: zoomW, height: zoomH),
             from: NSRect(x: shotCropX, y: cocoaShotCropY, width: shotCropW, height: shotCropH),
             operation: .sourceOver,
             fraction: 1.0)

// Draw cropped test (right)
let cocoaTestCropY = Double(repTest.pixelsHigh) - 10.0 - 170.0
imgTest.draw(in: NSRect(x: zoomW + 20.0, y: 0, width: zoomW, height: zoomH),
            from: NSRect(x: 30.0, y: cocoaTestCropY, width: 150.0, height: 170.0),
            operation: .sourceOver,
            fraction: 1.0)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/zoom_head_comparison.png"))
print("Saved scratch/zoom_head_comparison.png")
