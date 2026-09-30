import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790613333821.png")
let image = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!

let sMinX = 111.0
let sMinY = 31.0
let charW = 161.0
let charH = 466.0

func isBone(c: NSColor) -> Bool {
    let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
    // White bone
    if r > 0.85 && g > 0.85 && b > 0.85 { return true }
    // Blue accents inside bone (e.g. eye sockets, rib gaps, pelvis hole, spine discs)
    // Blue is around (r: 0.15..0.35, g: 0.45..0.65, b: 0.7..0.9)
    if b > 0.55 && b > r + 0.2 && g > 0.35 { return true }
    // Dark outline / teeth / eye socket dark
    if r < 0.2 && g < 0.2 && b < 0.35 && b > 0.15 { return true }
    return false
}

// 1. Skull
var skMinX = 999.0, skMaxX = 0.0, skMinY = 999.0, skMaxY = 0.0
for y in 30..<135 {
    for x in 120..<260 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < skMinX { skMinX = Double(x) }
            if Double(x) > skMaxX { skMaxX = Double(x) }
            if Double(y) < skMinY { skMinY = Double(y) }
            if Double(y) > skMaxY { skMaxY = Double(y) }
        }
    }
}

// 2. Ribcage
var ribMinX = 999.0, ribMaxX = 0.0, ribMinY = 999.0, ribMaxY = 0.0
for y in 130..<250 {
    for x in 125..<255 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < ribMinX { ribMinX = Double(x) }
            if Double(x) > ribMaxX { ribMaxX = Double(x) }
            if Double(y) < ribMinY { ribMinY = Double(y) }
            if Double(y) > ribMaxY { ribMaxY = Double(y) }
        }
    }
}

// 3. Pelvis
var pelMinX = 999.0, pelMaxX = 0.0, pelMinY = 999.0, pelMaxY = 0.0
for y in 260..<345 {
    for x in 135..<245 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < pelMinX { pelMinX = Double(x) }
            if Double(x) > pelMaxX { pelMaxX = Double(x) }
            if Double(y) < pelMinY { pelMinY = Double(y) }
            if Double(y) > pelMaxY { pelMaxY = Double(y) }
        }
    }
}

// 4. Arms
// Left Humerus (viewer's left: x ~ 110-155, y ~ 150-250)
var lHumMinX = 999.0, lHumMaxX = 0.0, lHumMinY = 999.0, lHumMaxY = 0.0
for y in 155..<240 {
    for x in 110..<145 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lHumMinX { lHumMinX = Double(x) }
            if Double(x) > lHumMaxX { lHumMaxX = Double(x) }
            if Double(y) < lHumMinY { lHumMinY = Double(y) }
            if Double(y) > lHumMaxY { lHumMaxY = Double(y) }
        }
    }
}

// Left Forearm / Radius Ulna (viewer's left: x ~ 105-140, y ~ 230-290)
var lRadMinX = 999.0, lRadMaxX = 0.0, lRadMinY = 999.0, lRadMaxY = 0.0
for y in 235..<290 {
    for x in 110..<140 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lRadMinX { lRadMinX = Double(x) }
            if Double(x) > lRadMaxX { lRadMaxX = Double(x) }
            if Double(y) < lRadMinY { lRadMinY = Double(y) }
            if Double(y) > lRadMaxY { lRadMaxY = Double(y) }
        }
    }
}

// Left Hand (viewer's left: x ~ 105-135, y ~ 285-330)
var lHandMinX = 999.0, lHandMaxX = 0.0, lHandMinY = 999.0, lHandMaxY = 0.0
for y in 285..<330 {
    for x in 110..<135 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lHandMinX { lHandMinX = Double(x) }
            if Double(x) > lHandMaxX { lHandMaxX = Double(x) }
            if Double(y) < lHandMinY { lHandMinY = Double(y) }
            if Double(y) > lHandMaxY { lHandMaxY = Double(y) }
        }
    }
}

// Right Humerus (viewer's right: x ~ 235-270, y ~ 155-240)
var rHumMinX = 999.0, rHumMaxX = 0.0, rHumMinY = 999.0, rHumMaxY = 0.0
for y in 155..<240 {
    for x in 238..<270 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rHumMinX { rHumMinX = Double(x) }
            if Double(x) > rHumMaxX { rHumMaxX = Double(x) }
            if Double(y) < rHumMinY { rHumMinY = Double(y) }
            if Double(y) > rHumMaxY { rHumMaxY = Double(y) }
        }
    }
}

// Right Forearm / Radius Ulna (viewer's right: x ~ 240-275, y ~ 235-290)
var rRadMinX = 999.0, rRadMaxX = 0.0, rRadMinY = 999.0, rRadMaxY = 0.0
for y in 235..<290 {
    for x in 240..<275 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rRadMinX { rRadMinX = Double(x) }
            if Double(x) > rRadMaxX { rRadMaxX = Double(x) }
            if Double(y) < rRadMinY { rRadMinY = Double(y) }
            if Double(y) > rRadMaxY { rRadMaxY = Double(y) }
        }
    }
}

// Right Hand (viewer's right: x ~ 245-275, y ~ 285-330)
var rHandMinX = 999.0, rHandMaxX = 0.0, rHandMinY = 999.0, rHandMaxY = 0.0
for y in 285..<330 {
    for x in 245..<275 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rHandMinX { rHandMinX = Double(x) }
            if Double(x) > rHandMaxX { rHandMaxX = Double(x) }
            if Double(y) < rHandMinY { rHandMinY = Double(y) }
            if Double(y) > rHandMaxY { rHandMaxY = Double(y) }
        }
    }
}

// 5. Legs
// Left Femur (viewer's left: x ~ 140-180, y ~ 310-405)
var lFemMinX = 999.0, lFemMaxX = 0.0, lFemMinY = 999.0, lFemMaxY = 0.0
for y in 315..<405 {
    for x in 140..<180 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lFemMinX { lFemMinX = Double(x) }
            if Double(x) > lFemMaxX { lFemMaxX = Double(x) }
            if Double(y) < lFemMinY { lFemMinY = Double(y) }
            if Double(y) > lFemMaxY { lFemMaxY = Double(y) }
        }
    }
}

// Left Tibia/Fibula (viewer's left: x ~ 140-175, y ~ 395-465)
var lTibMinX = 999.0, lTibMaxX = 0.0, lTibMinY = 999.0, lTibMaxY = 0.0
for y in 395..<465 {
    for x in 140..<175 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lTibMinX { lTibMinX = Double(x) }
            if Double(x) > lTibMaxX { lTibMaxX = Double(x) }
            if Double(y) < lTibMinY { lTibMinY = Double(y) }
            if Double(y) > lTibMaxY { lTibMaxY = Double(y) }
        }
    }
}

// Left Foot (viewer's left: x ~ 125-175, y ~ 455-495)
var lFootMinX = 999.0, lFootMaxX = 0.0, lFootMinY = 999.0, lFootMaxY = 0.0
for y in 455..<495 {
    for x in 125..<175 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < lFootMinX { lFootMinX = Double(x) }
            if Double(x) > lFootMaxX { lFootMaxX = Double(x) }
            if Double(y) < lFootMinY { lFootMinY = Double(y) }
            if Double(y) > lFootMaxY { lFootMaxY = Double(y) }
        }
    }
}

// Right Femur (viewer's right: x ~ 200-240, y ~ 315-405)
var rFemMinX = 999.0, rFemMaxX = 0.0, rFemMinY = 999.0, rFemMaxY = 0.0
for y in 315..<405 {
    for x in 200..<240 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rFemMinX { rFemMinX = Double(x) }
            if Double(x) > rFemMaxX { rFemMaxX = Double(x) }
            if Double(y) < rFemMinY { rFemMinY = Double(y) }
            if Double(y) > rFemMaxY { rFemMaxY = Double(y) }
        }
    }
}

// Right Tibia/Fibula (viewer's right: x ~ 205-240, y ~ 395-465)
var rTibMinX = 999.0, rTibMaxX = 0.0, rTibMinY = 999.0, rTibMaxY = 0.0
for y in 395..<465 {
    for x in 205..<240 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rTibMinX { rTibMinX = Double(x) }
            if Double(x) > rTibMaxX { rTibMaxX = Double(x) }
            if Double(y) < rTibMinY { rTibMinY = Double(y) }
            if Double(y) > rTibMaxY { rTibMaxY = Double(y) }
        }
    }
}

// Right Foot (viewer's right: x ~ 205-255, y ~ 455-495)
var rFootMinX = 999.0, rFootMaxX = 0.0, rFootMinY = 999.0, rFootMaxY = 0.0
for y in 455..<495 {
    for x in 205..<255 {
        guard let c = rep.colorAt(x: x, y: y) else { continue }
        if isBone(c: c) {
            if Double(x) < rFootMinX { rFootMinX = Double(x) }
            if Double(x) > rFootMaxX { rFootMaxX = Double(x) }
            if Double(y) < rFootMinY { rFootMinY = Double(y) }
            if Double(y) > rFootMaxY { rFootMaxY = Double(y) }
        }
    }
}

func printPiece(_ name: String, minX: Double, maxX: Double, minY: Double, maxY: Double) {
    let w = ((maxX - minX + 1) / charW) * 100.0
    let h = ((maxY - minY + 1) / charH) * 100.0
    let cx = (((minX + maxX) / 2.0 - sMinX) / charW) * 100.0
    let cy = (((minY + maxY) / 2.0 - sMinY) / charH) * 100.0
    print("\(name): px: [\(Int(minX))..\(Int(maxX)), \(Int(minY))..\(Int(maxY))] -> cx: \(String(format: "%.1f", cx))%, cy: \(String(format: "%.1f", cy))%, w: \(String(format: "%.1f", w))%, h: \(String(format: "%.1f", h))%")
}

printPiece("Skull", minX: skMinX, maxX: skMaxX, minY: skMinY, maxY: skMaxY)
printPiece("Ribcage", minX: ribMinX, maxX: ribMaxX, minY: ribMinY, maxY: ribMaxY)
printPiece("Pelvis", minX: pelMinX, maxX: pelMaxX, minY: pelMinY, maxY: pelMaxY)
printPiece("Left Humerus", minX: lHumMinX, maxX: lHumMaxX, minY: lHumMinY, maxY: lHumMaxY)
printPiece("Left Rad/Ulna", minX: lRadMinX, maxX: lRadMaxX, minY: lRadMinY, maxY: lRadMaxY)
printPiece("Left Hand", minX: lHandMinX, maxX: lHandMaxX, minY: lHandMinY, maxY: lHandMaxY)
printPiece("Right Humerus", minX: rHumMinX, maxX: rHumMaxX, minY: rHumMinY, maxY: rHumMaxY)
printPiece("Right Rad/Ulna", minX: rRadMinX, maxX: rRadMaxX, minY: rRadMinY, maxY: rRadMaxY)
printPiece("Right Hand", minX: rHandMinX, maxX: rHandMaxX, minY: rHandMinY, maxY: rHandMaxY)
printPiece("Left Femur", minX: lFemMinX, maxX: lFemMaxX, minY: lFemMinY, maxY: lFemMaxY)
printPiece("Left Tib/Fib", minX: lTibMinX, maxX: lTibMaxX, minY: lTibMinY, maxY: lTibMaxY)
printPiece("Left Foot", minX: lFootMinX, maxX: lFootMaxX, minY: lFootMinY, maxY: lFootMaxY)
printPiece("Right Femur", minX: rFemMinX, maxX: rFemMaxX, minY: rFemMinY, maxY: rFemMaxY)
printPiece("Right Tib/Fib", minX: rTibMinX, maxX: rTibMaxX, minY: rTibMinY, maxY: rTibMaxY)
printPiece("Right Foot", minX: rFootMinX, maxX: rFootMaxX, minY: rFootMinY, maxY: rFootMaxY)

