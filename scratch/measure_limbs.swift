import AppKit

let targetUrl = URL(fileURLWithPath: "scratch/user_younger_boy_target.png")
let targetImg = NSImage(contentsOf: targetUrl)!
let rep = NSBitmapImageRep(data: targetImg.tiffRepresentation!)!
let W = rep.pixelsWide
let H = rep.pixelsHigh

func isBonePixel(_ c: NSColor) -> Bool {
    // Bone colors are white/light blue or blue accents
    let isWhite = c.redComponent > 0.75 && c.greenComponent > 0.75 && c.blueComponent > 0.75
    let isBlue = c.blueComponent > 0.55 && c.redComponent < 0.45 && c.greenComponent < 0.7
    return isWhite || isBlue
}

// 1. Skull: y from 0 to 110
var skullMinX = W, skullMaxX = 0, skullMinY = H, skullMaxY = 0
for y in 0..<110 {
    for x in 0..<W {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            skullMinX = min(skullMinX, x)
            skullMaxX = max(skullMaxX, x)
            skullMinY = min(skullMinY, y)
            skullMaxY = max(skullMaxY, y)
        }
    }
}
print(String(format: "Skull: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    skullMinX, skullMaxX, skullMaxX - skullMinX, Double(skullMaxX - skullMinX)/Double(W)*100.0,
    skullMinY, skullMaxY, skullMaxY - skullMinY, Double(skullMaxY - skullMinY)/Double(H)*100.0,
    Double(skullMinX + skullMaxX)/2.0/Double(W)*100.0, Double(skullMinY + skullMaxY)/2.0/Double(H)*100.0))

// 2. Ribcage: y from 120 to 225, x between 25 and 135
var ribMinX = W, ribMaxX = 0, ribMinY = H, ribMaxY = 0
for y in 120..<225 {
    for x in 25..<135 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            ribMinX = min(ribMinX, x)
            ribMaxX = max(ribMaxX, x)
            ribMinY = min(ribMinY, y)
            ribMaxY = max(ribMaxY, y)
        }
    }
}
print(String(format: "Ribcage: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    ribMinX, ribMaxX, ribMaxX - ribMinX, Double(ribMaxX - ribMinX)/Double(W)*100.0,
    ribMinY, ribMaxY, ribMaxY - ribMinY, Double(ribMaxY - ribMinY)/Double(H)*100.0,
    Double(ribMinX + ribMaxX)/2.0/Double(W)*100.0, Double(ribMinY + ribMaxY)/2.0/Double(H)*100.0))

// 3. Pelvis: y from 225 to 295, x between 30 and 130
var pelMinX = W, pelMaxX = 0, pelMinY = H, pelMaxY = 0
for y in 225..<295 {
    for x in 30..<130 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            pelMinX = min(pelMinX, x)
            pelMaxX = max(pelMaxX, x)
            pelMinY = min(pelMinY, y)
            pelMaxY = max(pelMaxY, y)
        }
    }
}
print(String(format: "Pelvis: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    pelMinX, pelMaxX, pelMaxX - pelMinX, Double(pelMaxX - pelMinX)/Double(W)*100.0,
    pelMinY, pelMaxY, pelMaxY - pelMinY, Double(pelMaxY - pelMinY)/Double(H)*100.0,
    Double(pelMinX + pelMaxX)/2.0/Double(W)*100.0, Double(pelMinY + pelMaxY)/2.0/Double(H)*100.0))

// 4. Left Arm (humerus: y 135..215, x 0..35)
var lHumMinX = W, lHumMaxX = 0, lHumMinY = H, lHumMaxY = 0
for y in 135..<215 {
    for x in 0..<35 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lHumMinX = min(lHumMinX, x)
            lHumMaxX = max(lHumMaxX, x)
            lHumMinY = min(lHumMinY, y)
            lHumMaxY = max(lHumMaxY, y)
        }
    }
}
print(String(format: "Left Humerus: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lHumMinX, lHumMaxX, lHumMaxX - lHumMinX, Double(lHumMaxX - lHumMinX)/Double(W)*100.0,
    lHumMinY, lHumMaxY, lHumMaxY - lHumMinY, Double(lHumMaxY - lHumMinY)/Double(H)*100.0,
    Double(lHumMinX + lHumMaxX)/2.0/Double(W)*100.0, Double(lHumMinY + lHumMaxY)/2.0/Double(H)*100.0))

// 5. Left Forearm (radius/ulna: y 200..260, x 0..25)
var lRadMinX = W, lRadMaxX = 0, lRadMinY = H, lRadMaxY = 0
for y in 200..<260 {
    for x in 0..<25 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lRadMinX = min(lRadMinX, x)
            lRadMaxX = max(lRadMaxX, x)
            lRadMinY = min(lRadMinY, y)
            lRadMaxY = max(lRadMaxY, y)
        }
    }
}
print(String(format: "Left Forearm: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lRadMinX, lRadMaxX, lRadMaxX - lRadMinX, Double(lRadMaxX - lRadMinX)/Double(W)*100.0,
    lRadMinY, lRadMaxY, lRadMaxY - lRadMinY, Double(lRadMaxY - lRadMinY)/Double(H)*100.0,
    Double(lRadMinX + lRadMaxX)/2.0/Double(W)*100.0, Double(lRadMinY + lRadMaxY)/2.0/Double(H)*100.0))

// 6. Left Hand: y 240..290, x 0..20
var lHandMinX = W, lHandMaxX = 0, lHandMinY = H, lHandMaxY = 0
for y in 240..<290 {
    for x in 0..<20 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lHandMinX = min(lHandMinX, x)
            lHandMaxX = max(lHandMaxX, x)
            lHandMinY = min(lHandMinY, y)
            lHandMaxY = max(lHandMaxY, y)
        }
    }
}
print(String(format: "Left Hand: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lHandMinX, lHandMaxX, lHandMaxX - lHandMinX, Double(lHandMaxX - lHandMinX)/Double(W)*100.0,
    lHandMinY, lHandMaxY, lHandMaxY - lHandMinY, Double(lHandMaxY - lHandMinY)/Double(H)*100.0,
    Double(lHandMinX + lHandMaxX)/2.0/Double(W)*100.0, Double(lHandMinY + lHandMaxY)/2.0/Double(H)*100.0))

// 7. Left Femur: y 270..360, x 35..80
var lFemMinX = W, lFemMaxX = 0, lFemMinY = H, lFemMaxY = 0
for y in 270..<360 {
    for x in 35..<80 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lFemMinX = min(lFemMinX, x)
            lFemMaxX = max(lFemMaxX, x)
            lFemMinY = min(lFemMinY, y)
            lFemMaxY = max(lFemMaxY, y)
        }
    }
}
print(String(format: "Left Femur: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lFemMinX, lFemMaxX, lFemMaxX - lFemMinX, Double(lFemMaxX - lFemMinX)/Double(W)*100.0,
    lFemMinY, lFemMaxY, lFemMaxY - lFemMinY, Double(lFemMaxY - lFemMinY)/Double(H)*100.0,
    Double(lFemMinX + lFemMaxX)/2.0/Double(W)*100.0, Double(lFemMinY + lFemMaxY)/2.0/Double(H)*100.0))

// 8. Left Tibia/Fibula: y 340..425, x 35..75
var lTibMinX = W, lTibMaxX = 0, lTibMinY = H, lTibMaxY = 0
for y in 340..<425 {
    for x in 35..<75 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lTibMinX = min(lTibMinX, x)
            lTibMaxX = max(lTibMaxX, x)
            lTibMinY = min(lTibMinY, y)
            lTibMaxY = max(lTibMaxY, y)
        }
    }
}
print(String(format: "Left Tibia: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lTibMinX, lTibMaxX, lTibMaxX - lTibMinX, Double(lTibMaxX - lTibMinX)/Double(W)*100.0,
    lTibMinY, lTibMaxY, lTibMaxY - lTibMinY, Double(lTibMaxY - lTibMinY)/Double(H)*100.0,
    Double(lTibMinX + lTibMaxX)/2.0/Double(W)*100.0, Double(lTibMinY + lTibMaxY)/2.0/Double(H)*100.0))

// 9. Left Foot: y 415..450, x 35..75
var lFootMinX = W, lFootMaxX = 0, lFootMinY = H, lFootMaxY = 0
for y in 415..<450 {
    for x in 35..<75 {
        if isBonePixel(rep.colorAt(x: x, y: y)!) {
            lFootMinX = min(lFootMinX, x)
            lFootMaxX = max(lFootMaxX, x)
            lFootMinY = min(lFootMinY, y)
            lFootMaxY = max(lFootMaxY, y)
        }
    }
}
print(String(format: "Left Foot: x: %d..%d (w:%d, %.1f%%), y: %d..%d (h:%d, %.1f%%), center: (%.1f%%, %.1f%%)",
    lFootMinX, lFootMaxX, lFootMaxX - lFootMinX, Double(lFootMaxX - lFootMinX)/Double(W)*100.0,
    lFootMinY, lFootMaxY, lFootMaxY - lFootMinY, Double(lFootMaxY - lFootMinY)/Double(H)*100.0,
    Double(lFootMinX + lFootMaxX)/2.0/Double(W)*100.0, Double(lFootMinY + lFootMaxY)/2.0/Double(H)*100.0))
