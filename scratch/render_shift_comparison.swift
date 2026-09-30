import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let soloImg = NSImage(contentsOf: soloUrl)!
let charW = 220.0
let charH = 681.0

// Load user screenshot
let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotImg = NSImage(contentsOf: shotUrl)!

// Let's create a 3-panel comparison:
// Panel 1: User Reference Screenshot (cropped to character)
// Panel 2: Candidate with dx=-20, dy=+24
// Panel 3: Candidate with dx=-20, dy=+28

let compW = 220 * 3 + 20
let compH = 681
let canvas = NSImage(size: NSSize(width: compW, height: compH))
canvas.lockFocus()

// Fill background with theatrical purple #543fa6
NSColor(calibratedRed: 0.33, green: 0.25, blue: 0.65, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: compW, height: compH).fill()

// Panel 1: Draw screenshot character region (x: 42..179, y: 25..450 -> w: 138, h: 426)
// In Cocoa NSImage.draw, fromRect has y=0 at bottom
let shotRep = NSBitmapImageRep(data: shotImg.tiffRepresentation!)!
let shotH_px = Double(shotRep.pixelsHigh)
let fromShotY = shotH_px - 450.0 // bottom
let fromShotRect = NSRect(x: 42, y: fromShotY, width: 138, height: 426)
shotImg.draw(in: NSRect(x: 0, y: 0, width: 220, height: 681), from: fromShotRect, operation: .sourceOver, fraction: 1.0)

// Helper to draw candidate
func drawCandidate(path: String, atX: Double) {
    soloImg.draw(in: NSRect(x: atX, y: 0, width: 220, height: 681))
    guard let skelImg = NSImage(contentsOf: URL(fileURLWithPath: path)),
          let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else { return }
    
    // Find bounds in candidate image
    var minX = skelRep.pixelsWide, maxX = 0, minY = skelRep.pixelsHigh, maxY = 0
    for y in 0..<skelRep.pixelsHigh {
        for x in 0..<skelRep.pixelsWide {
            if skelRep.colorAt(x: x, y: y)!.alphaComponent > 0.3 {
                minX = min(minX, x)
                maxX = max(maxX, x)
                minY = min(minY, y)
                maxY = max(maxY, y)
            }
        }
    }
    
    let cropW = maxX - minX + 1
    let cropH = maxY - minY + 1
    let skelH_px = Double(skelRep.pixelsHigh)
    let fromY = skelH_px - Double(maxY + 1)
    let fromRect = NSRect(x: minX, y: Int(fromY), width: cropW, height: cropH)
    
    // Position on 220x681 character:
    // Screenshot placement: left: 2.90%, top: 1.88%, width: 89.13%, height: 97.65%
    let destX = atX + 0.0290 * 220.0
    let destW = 0.8913 * 220.0
    let destH = 0.9765 * 681.0
    let destY = 681.0 - (0.0188 * 681.0) - destH
    
    skelImg.draw(in: NSRect(x: destX, y: destY, width: destW, height: destH), from: fromRect, operation: .sourceOver, fraction: 1.0)
}

// Panel 2: dx=-20, dy=+24
drawCandidate(path: "scratch/test_shift_dx-20_dy+24.png", atX: 230)

// Panel 3: dx=-20, dy=+28
drawCandidate(path: "scratch/test_shift_dx-20_dy+28.png", atX: 460)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/shift_comparison_3panel.png"))
print("Saved scratch/shift_comparison_3panel.png")

