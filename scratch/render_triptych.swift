import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let imgSolo = NSImage(contentsOf: urlSolo)!
let repSolo = NSBitmapImageRep(data: imgSolo.tiffRepresentation!)!
let charW = Double(repSolo.pixelsWide) // 220
let charH = Double(repSolo.pixelsHigh) // 681

let pinkSilhouetteRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(charW), pixelsHigh: Int(charH), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
for y in 0..<Int(charH) {
    for x in 0..<Int(charW) {
        let c = repSolo.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            pinkSilhouetteRep.setColor(NSColor(calibratedRed: 1.0, green: 0.655, blue: 0.929, alpha: c.alphaComponent), atX: x, y: y)
        } else {
            pinkSilhouetteRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}
let imgPink = NSImage(data: pinkSilhouetteRep.representation(using: .png, properties: [:])!)!

// Load assembled skeleton
let urlSkel = URL(fileURLWithPath: "assets/Skeleton_OlderBoy_Assembled.png")
let imgSkel = NSImage(contentsOf: urlSkel)!

let outW = 220.0 * 3.0 + 60.0
let outH = 681.0 + 50.0

let canvas = NSImage(size: NSSize(width: outW, height: outH))
canvas.lockFocus()

NSColor(calibratedWhite: 0.12, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: outW, height: outH).fill()

// Panel 1: User's Reference Screenshot
let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let imgShot = NSImage(contentsOf: urlShot)!
let repShot = NSBitmapImageRep(data: imgShot.tiffRepresentation!)!

let scale = 681.0 / 426.0
let shotDrawX = 15.0 - 43.0 * scale
let shotDrawY = 15.0 - (Double(repShot.pixelsHigh) * scale - 450.0 * scale)
imgShot.draw(in: NSRect(x: shotDrawX, y: shotDrawY, width: Double(repShot.pixelsWide) * scale, height: Double(repShot.pixelsHigh) * scale),
             from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

// Panel 2: Pink Silhouette + Assembled Skeleton
let p2X = 220.0 + 30.0
imgPink.draw(in: NSRect(x: p2X, y: 15.0, width: charW, height: charH))
imgSkel.draw(in: NSRect(x: p2X, y: 15.0, width: charW, height: charH))

// Panel 3: Solo Character + Assembled Skeleton
let p3X = 220.0 * 2.0 + 45.0
imgSolo.draw(in: NSRect(x: p3X, y: 15.0, width: charW, height: charH))
imgSkel.draw(in: NSRect(x: p3X, y: 15.0, width: charW, height: charH))

// Titles
let font = NSFont.boldSystemFont(ofSize: 13.0)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white
]

"1. User Reference Screenshot".draw(at: NSPoint(x: 25.0, y: 681.0 + 20.0), withAttributes: attrs)
"2. Reassembled Bones (Pink)".draw(at: NSPoint(x: p2X + 10.0, y: 681.0 + 20.0), withAttributes: attrs)
"3. Final In-App Presentation".draw(at: NSPoint(x: p3X + 15.0, y: 681.0 + 20.0), withAttributes: attrs)

canvas.unlockFocus()

let rep = NSBitmapImageRep(data: canvas.tiffRepresentation!)!
let png = rep.representation(using: .png, properties: [:])!
let targetUrl = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/older_boy_skeleton_final_verification.png")
try! png.write(to: targetUrl)
print("Saved final verification triptych to \(targetUrl.path)")
