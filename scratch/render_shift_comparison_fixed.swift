import AppKit

let soloUrl = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let soloImg = NSImage(contentsOf: soloUrl)!

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotImg = NSImage(contentsOf: shotUrl)!

let compW = 220 * 3 + 20
let compH = 681
let canvas = NSImage(size: NSSize(width: compW, height: compH))
canvas.lockFocus()

NSColor(calibratedRed: 0.33, green: 0.25, blue: 0.65, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: compW, height: compH).fill()

// Panel 1: User screenshot
let shotRep = NSBitmapImageRep(data: shotImg.tiffRepresentation!)!
let shotH_px = Double(shotRep.pixelsHigh)
let fromShotY = shotH_px - 450.0
let fromShotRect = NSRect(x: 42, y: fromShotY, width: 138, height: 426)
shotImg.draw(in: NSRect(x: 0, y: 0, width: 220, height: 681), from: fromShotRect, operation: .sourceOver, fraction: 1.0)

// Helper to draw candidate
func drawCandidate(path: String, atX: Double) {
    soloImg.draw(in: NSRect(x: atX, y: 0, width: 220, height: 681))
    guard let skelImg = NSImage(contentsOf: URL(fileURLWithPath: path)),
          let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
        print("Failed to load \(path)")
        return
    }
    
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
    let cropRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: cropW, pixelsHigh: cropH, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    
    for y in 0..<cropH {
        for x in 0..<cropW {
            cropRep.setColor(skelRep.colorAt(x: minX + x, y: minY + y)!, atX: x, y: y)
        }
    }
    
    let croppedImg = NSImage(data: cropRep.representation(using: .png, properties: [:])!)!
    
    // Position on 220x681 character:
    let destX = atX + 0.0290 * 220.0
    let destW = 0.8913 * 220.0
    let destH = 0.9765 * 681.0
    let destY = 681.0 - (0.0188 * 681.0) - destH
    
    croppedImg.draw(in: NSRect(x: destX, y: destY, width: destW, height: destH), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)
}

drawCandidate(path: "scratch/test_shift_dx-20_dy24.png", atX: 230)
drawCandidate(path: "scratch/test_shift_dx-20_dy28.png", atX: 460)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/shift_comparison_3panel_fixed.png"))
print("Saved scratch/shift_comparison_3panel_fixed.png")

