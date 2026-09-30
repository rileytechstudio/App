import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let files = [
    "scratch/test_shift_dx8_dy0.png",
    "scratch/test_shift_dx10_dy0.png",
    "scratch/test_shift_dx12_dy0.png",
    "scratch/test_shift_dx10_dy2.png"
]

// Canvas with 5 columns: Screenshot, dx8, dx10, dx12, dx10_dy2
let colW = 220.0
let outW = colW * 5.0 + 40.0
let outH = 681.0

let canvas = NSImage(size: NSSize(width: outW, height: outH))
canvas.lockFocus()

NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: outW, height: outH).fill()

// Draw Shot (col 0)
let scale = 681.0 / 426.0
let shotDrawX = 0.0 - 43.0 * scale
let shotDrawY = 0.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

for (i, f) in files.enumerated() {
    let img = NSImage(contentsOf: URL(fileURLWithPath: f))!
    let x = colW * Double(i + 1) + Double(i + 1) * 10.0
    img.draw(in: NSRect(x: x, y: 0, width: colW, height: outH),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)
}

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/shifts_vs_shot.png"))
print("Saved scratch/shifts_vs_shot.png")
