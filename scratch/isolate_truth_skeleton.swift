import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

// Crop exactly x: 117..282 (w: 166), y: 125..635 (h: 511)
let pw = 166
let ph = 511

let skelRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

let pinkRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<ph {
    for x in 0..<pw {
        let sx = 117 + x
        let sy = 125 + y
        let c = rep.colorAt(x: sx, y: sy)!
        guard c.alphaComponent > 0.05 else {
            skelRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            pinkRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            continue
        }
        
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Is it pink silhouette?
        // Pink in this file: r > 0.85, g < 0.65, b > 0.85
        let isPink = (r > 0.85 && g < 0.65 && b > 0.85)
        
        if isPink {
            pinkRep.setColor(c, atX: x, y: y)
            skelRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        } else {
            // It is skeleton!
            skelRep.setColor(c, atX: x, y: y)
            pinkRep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let skelPng = skelRep.representation(using: .png, properties: [:])!
try! skelPng.write(to: URL(fileURLWithPath: "scratch/truth_skeleton.png"))

let pinkPng = pinkRep.representation(using: .png, properties: [:])!
try! pinkPng.write(to: URL(fileURLWithPath: "scratch/truth_pink.png"))

print("Saved scratch/truth_skeleton.png and scratch/truth_pink.png")
