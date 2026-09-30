import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// In repSkel, skeleton bbox was:
// x: 596..1010 (w: 415), y: 371..1633 (h: 1263)

// In repShot:
// Skeleton bbox was:
// x: 46..167 (w: 122), y: 33..447 (h: 415)

// Ratio of height: 415 / 1263 = 0.32858
// Ratio of width: 122 / 415 = 0.29397

// Let's check feature landmarks in both!
// In repSkel:
// Top of skull: y = 371
// Bottom of jaw: y = 536 (distance = 165)
// Top of clavicles: y = 625 (distance from top = 254)
// Bottom of ribs: y = 865 (distance from top = 494)
// Bottom of pelvis: y = 1080 (distance from top = 709)
// Knees (femur bottom): y = 1315 (distance from top = 944)
// Bottom of feet: y = 1633 (distance from top = 1262)

// Now let's measure the SAME landmarks in repShot:
// Top of skull: y = 33
// Clavicle top:
var shotClavY = 0
for y in 33...200 {
    for x in 60...100 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8 && y > 100 {
            if shotClavY == 0 { shotClavY = y }
        }
    }
}

// Let's find pelvis bottom in repShot:
var shotPelvisBottomY = 0
for y in 200...300 {
    var boneInCenter = false
    for x in 90...115 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent > 0.7 && c.greenComponent > 0.7 && c.blueComponent > 0.7 {
            boneInCenter = true
        }
    }
    if boneInCenter { shotPelvisBottomY = y }
}

print("repSkel relative vertical positions (% of total skeleton height):")
print("  Skull top: 0%")
print("  Jaw bottom: \(Double(536 - 371) / 12.63)%")
print("  Clavicle top: \(Double(625 - 371) / 12.63)%")
print("  Ribs bottom: \(Double(865 - 371) / 12.63)%")
print("  Pelvis bottom: \(Double(1080 - 371) / 12.63)%")
print("  Knees: \(Double(1315 - 371) / 12.63)%")
print("  Feet bottom: 100%")

print("\nrepShot landmarks:")
print("  Skull top: 33 (0%)")
print("  Clavicle top: \(shotClavY) (\(Double(shotClavY - 33) / 4.15)%)")
print("  Pelvis bottom: \(shotPelvisBottomY) (\(Double(shotPelvisBottomY - 33) / 4.15)%)")
