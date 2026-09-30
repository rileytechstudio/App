import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Background color: #5740A8 -> (0.341, 0.251, 0.659)
let bgR = 0.3412
let bgG = 0.2510
let bgB = 0.6588

func unmattePixel(x: Int, y: Int) -> NSColor? {
    guard x >= 0 && x < repSkel.pixelsWide && y >= 0 && y < repSkel.pixelsHigh else { return nil }
    let c = repSkel.colorAt(x: x, y: y)!
    let r = Double(c.redComponent)
    let g = Double(c.greenComponent)
    let b = Double(c.blueComponent)
    
    let dr = r - bgR
    let dg = g - bgG
    let db = b - bgB
    let dist = sqrt(dr * dr + dg * dg + db * db)
    
    if dist < 0.10 {
        return nil // pure background
    }
    
    // For pixels close to background, unmix background
    if dist < 0.25 {
        let alpha = min(1.0, max(0.0, (dist - 0.08) / (0.25 - 0.08)))
        // Unmix foreground: c = a*fg + (1-a)*bg => fg = (c - (1-a)*bg) / a
        let fgR = min(1.0, max(0.0, (r - (1.0 - alpha) * bgR) / alpha))
        let fgG = min(1.0, max(0.0, (g - (1.0 - alpha) * bgG) / alpha))
        let fgB = min(1.0, max(0.0, (b - (1.0 - alpha) * bgB) / alpha))
        return NSColor(calibratedRed: fgR, green: fgG, blue: fgB, alpha: alpha)
    }
    
    return c
}

// Extract skull: x: 700..863, y: 372..536
let pw = 863 - 700 + 1
let ph = 536 - 372 + 1
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pw, pixelsHigh: ph, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!

for y in 0..<ph {
    for x in 0..<pw {
        let sx = 700 + x
        let sy = 372 + y
        // Exclude spine fragment below jaw (x < 745 && y > 515 in source)
        if sx < 745 && sy > 515 {
            rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            continue
        }
        if let col = unmattePixel(x: sx, y: sy) {
            rep.setColor(col, atX: x, y: y)
        } else {
            rep.setColor(NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
        }
    }
}

let data = rep.representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: "scratch/unmatted_skull.png"))
print("Saved scratch/unmatted_skull.png")
