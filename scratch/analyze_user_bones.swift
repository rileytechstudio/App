import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let image = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!

let sMinX = 111.0
let sMinY = 31.0
let charW = 161.0
let charH = 466.0

func toCharPct(px: Double, py: Double) -> (xPct: Double, yPct: Double) {
    let xPct = ((px - sMinX) / charW) * 100.0
    let yPct = ((py - sMinY) / charH) * 100.0
    return (xPct, yPct)
}

func toCharRectPct(minX: Double, maxX: Double, minY: Double, maxY: Double) -> (cx: Double, cy: Double, w: Double, h: Double) {
    let w = ((maxX - minX) / charW) * 100.0
    let h = ((maxY - minY) / charH) * 100.0
    let cx = (((minX + maxX) / 2.0 - sMinX) / charW) * 100.0
    let cy = (((minY + maxY) / 2.0 - sMinY) / charH) * 100.0
    return (cx, cy, w, h)
}

// Let's inspect specific regions:
// 1. Skull region: y from 30 to 125, x from 140 to 240
var skullMinX = 999.0, skullMaxX = 0.0, skullMinY = 999.0, skullMaxY = 0.0
for y in 31..<130 {
    for x in 140..<245 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        // Skull is white or blue outline/teeth
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Is it part of skull? Not silhouette olive (r:0.7, g:0.77, b:0.52)
        let isOlive = (r > 0.65 && r < 0.85 && g > 0.7 && g < 0.85 && b > 0.45 && b < 0.6)
        let isPurple = (r < 0.4 && g < 0.3 && b > 0.6)
        if !isOlive && !isPurple {
            if Double(x) < skullMinX { skullMinX = Double(x) }
            if Double(x) > skullMaxX { skullMaxX = Double(x) }
            if Double(y) < skullMinY { skullMinY = Double(y) }
            if Double(y) > skullMaxY { skullMaxY = Double(y) }
        }
    }
}
let skullPct = toCharRectPct(minX: skullMinX, maxX: skullMaxX, minY: skullMinY, maxY: skullMaxY)
print("Skull in px: x: [\(skullMinX), \(skullMaxX)], y: [\(skullMinY), \(skullMaxY)]")
print("Skull: cx: \(String(format: "%.1f", skullPct.cx))%, cy: \(String(format: "%.1f", skullPct.cy))%, w: \(String(format: "%.1f", skullPct.w))%, h: \(String(format: "%.1f", skullPct.h))%")

// 2. Ribcage region: y from 135 to 255, x from 130 to 250
var ribMinX = 999.0, ribMaxX = 0.0, ribMinY = 999.0, ribMaxY = 0.0
for y in 140..<250 {
    for x in 140..<245 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isOlive = (r > 0.65 && r < 0.85 && g > 0.7 && g < 0.85 && b > 0.45 && b < 0.6)
        let isPurple = (r < 0.4 && g < 0.3 && b > 0.6)
        if !isOlive && !isPurple {
            if Double(x) < ribMinX { ribMinX = Double(x) }
            if Double(x) > ribMaxX { ribMaxX = Double(x) }
            if Double(y) < ribMinY { ribMinY = Double(y) }
            if Double(y) > ribMaxY { ribMaxY = Double(y) }
        }
    }
}
let ribPct = toCharRectPct(minX: ribMinX, maxX: ribMaxX, minY: ribMinY, maxY: ribMaxY)
print("Ribcage in px: x: [\(ribMinX), \(ribMaxX)], y: [\(ribMinY), \(ribMaxY)]")
print("Ribcage: cx: \(String(format: "%.1f", ribPct.cx))%, cy: \(String(format: "%.1f", ribPct.cy))%, w: \(String(format: "%.1f", ribPct.w))%, h: \(String(format: "%.1f", ribPct.h))%")

// 3. Pelvis region: y from 265 to 335, x from 145 to 240
var pelMinX = 999.0, pelMaxX = 0.0, pelMinY = 999.0, pelMaxY = 0.0
for y in 265..<335 {
    for x in 145..<240 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isOlive = (r > 0.65 && r < 0.85 && g > 0.7 && g < 0.85 && b > 0.45 && b < 0.6)
        let isPurple = (r < 0.4 && g < 0.3 && b > 0.6)
        if !isOlive && !isPurple {
            if Double(x) < pelMinX { pelMinX = Double(x) }
            if Double(x) > pelMaxX { pelMaxX = Double(x) }
            if Double(y) < pelMinY { pelMinY = Double(y) }
            if Double(y) > pelMaxY { pelMaxY = Double(y) }
        }
    }
}
let pelPct = toCharRectPct(minX: pelMinX, maxX: pelMaxX, minY: pelMinY, maxY: pelMaxY)
print("Pelvis in px: x: [\(pelMinX), \(pelMaxX)], y: [\(pelMinY), \(pelMaxY)]")
print("Pelvis: cx: \(String(format: "%.1f", pelPct.cx))%, cy: \(String(format: "%.1f", pelPct.cy))%, w: \(String(format: "%.1f", pelPct.w))%, h: \(String(format: "%.1f", pelPct.h))%")

// 4. Spine top & bottom
var spineTopY = 999.0, spineBotY = 0.0
for y in 100..<310 {
    // Spine center line is x around 191
    for x in 188...194 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isOlive = (r > 0.65 && r < 0.85 && g > 0.7 && g < 0.85 && b > 0.45 && b < 0.6)
        let isPurple = (r < 0.4 && g < 0.3 && b > 0.6)
        if !isOlive && !isPurple {
            if Double(y) < spineTopY { spineTopY = Double(y) }
            if Double(y) > spineBotY { spineBotY = Double(y) }
        }
    }
}
let spinePct = toCharRectPct(minX: 185, maxX: 197, minY: spineTopY, maxY: spineBotY)
print("Spine in px: y: [\(spineTopY), \(spineBotY)]")
print("Spine: cx: \(String(format: "%.1f", spinePct.cx))%, cy: \(String(format: "%.1f", spinePct.cy))%, w: \(String(format: "%.1f", spinePct.w))%, h: \(String(format: "%.1f", spinePct.h))%")

