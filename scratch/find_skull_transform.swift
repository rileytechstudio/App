import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// In screenshot:
// Skull eye socket (orbit):
// Orbit is the dark patch in the skull.
var shotOrbitX = 0.0, shotOrbitY = 0.0, shotOrbitCount = 0.0
for y in 40...70 {
    for x in 110...130 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.blueComponent < 0.35 && c.greenComponent < 0.25 {
            shotOrbitX += Double(x)
            shotOrbitY += Double(y)
            shotOrbitCount += 1.0
        }
    }
}
print("Shot orbit centroid: (\(shotOrbitX / shotOrbitCount), \(shotOrbitY / shotOrbitCount))")

// In Older Boy Skeleton:
var skelOrbitX = 0.0, skelOrbitY = 0.0, skelOrbitCount = 0.0
for y in 440...500 {
    for x in 820...855 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent < 0.25 && c.blueComponent < 0.35 && c.greenComponent < 0.25 {
            skelOrbitX += Double(x)
            skelOrbitY += Double(y)
            skelOrbitCount += 1.0
        }
    }
}
print("Skel orbit centroid: (\(skelOrbitX / skelOrbitCount), \(skelOrbitY / skelOrbitCount))")

// In Older Boy Skeleton, the skeleton bbox is x: 596..1010 (w: 415), y: 371..1633 (h: 1263).
// If we map Skel to Shot (x: 46, y: 33, w: 122, h: 415):
let scaleX = 122.0 / 415.0
let scaleY = 415.0 / 1263.0
let expectedOrbitX = 46.0 + (skelOrbitX / skelOrbitCount - 596.0) * scaleX
let expectedOrbitY = 33.0 + (skelOrbitY / skelOrbitCount - 371.0) * scaleY

print("Expected orbit in Shot if uniform scaling: (\(expectedOrbitX), \(expectedOrbitY))")
print("Difference (Shot - Expected): dx = \((shotOrbitX / shotOrbitCount) - expectedOrbitX), dy = \((shotOrbitY / shotOrbitCount) - expectedOrbitY)")
