import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

// Skeleton bbox in Older Boy Skeleton.png
let srcMinX = 596.0
let srcMinY = 371.0
let srcW = 415.0
let srcH = 1263.0

// Placement on Character_OlderBoy_Solo.png:
// skel_minX_px = 4.85, skel_w_px = 197.35
// skel_minY_px = 12.79, skel_h_px = 663.42
let destMinX = 4.85
let destMinY = 12.79
let destW = 197.35
let destH = 663.42

// Let's create a clean rep of Older Boy Skeleton (transparent bg)
let cleanSkelRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(srcW), pixelsHigh: Int(srcH), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<Int(srcH) {
    for x in 0..<Int(srcW) {
        let sx = Int(srcMinX) + x
        let sy = Int(srcMinY) + y
        let c = repSkel.colorAt(x: sx, y: sy)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        
        let isWhite = (r > 0.78 && g > 0.78 && b > 0.78)
        let isShading = (b > 0.38 && g > 0.32 && g > r + 0.03)
        let isCavity = (sx >= 810 && sx <= 865 && sy >= 440 && sy <= 515 && r < 0.25 && g < 0.25 && b < 0.35)
        
        if isWhite || isShading || isCavity {
            cleanSkelRep.setColor(c, atX: x, y: y)
        } else {
            cleanSkelRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let canvas = NSImage(size: NSSize(width: charW, height: charH))
canvas.lockFocus()

// Draw character solo
imgSolo.draw(in: NSRect(x: 0, y: 0, width: charW, height: charH))

// Draw clean skeleton
let skelImg = NSImage(data: cleanSkelRep.representation(using: .png, properties: [:])!)!
let cocoaY = charH - destMinY - destH
skelImg.draw(in: NSRect(x: destMinX, y: cocoaY, width: destW, height: destH),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

canvas.unlockFocus()

let outRep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let outPng = outRep.representation(using: .png, properties: [:])!
try! outPng.write(to: URL(fileURLWithPath: "scratch/exact_formula_on_solo.png"))
print("Saved scratch/exact_formula_on_solo.png")

// Now compare side by side with the screenshot!
let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let sideCanvas = NSImage(size: NSSize(width: 480, height: 681))
sideCanvas.lockFocus()

NSColor(calibratedWhite: 0.15, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: 480, height: 681).fill()

// Draw shot (left side) scaled to match character height 681
let scale = 681.0 / 426.0
let shotDrawX = 20.0 - 43.0 * scale
let shotDrawY = 0.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero,
             operation: .sourceOver,
             fraction: 1.0)

// Draw our exact formula (right side)
canvas.draw(in: NSRect(x: 240, y: 0, width: charW, height: charH),
            from: NSRect.zero,
            operation: .sourceOver,
            fraction: 1.0)

sideCanvas.unlockFocus()

let sideRep = NSBitmapImageRep(data: sideCanvas.tiffRepresentation!)!
let sidePng = sideRep.representation(using: .png, properties: [:])!
try! sidePng.write(to: URL(fileURLWithPath: "scratch/side_by_side_exact_formula.png"))
print("Saved scratch/side_by_side_exact_formula.png")
