import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Isolate pelvis:
// In y: 920..1100, x: 670..890:
// On the left, at x < 720, y > 960 is the hand.
// On the left, at x < 690, y < 960 is the radius/ulna.
// Let's check where the pelvis bone actually exists!
var pMinX = 9999, pMaxX = 0, pMinY = 9999, pMaxY = 0
for y in 920...1120 {
    for x in 670...900 {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        let isBone = (r > 0.78 && g > 0.78 && b > 0.78) || (b > 0.38 && g > 0.32 && g > r + 0.03)
        if isBone {
            // Exclude left hand:
            if x < 720 && y > 970 { continue }
            // Exclude forearm:
            if x < 690 && y < 970 { continue }
            // Exclude right hand:
            if x > 885 && y > 970 { continue }
            // Exclude right forearm:
            if x > 880 && y < 970 { continue }
            
            pMinX = min(pMinX, x)
            pMaxX = max(pMaxX, x)
            pMinY = min(pMinY, y)
            pMaxY = max(pMaxY, y)
        }
    }
}
print("Pelvis extents: x: \(pMinX)..\(pMaxX) (w: \(pMaxX - pMinX + 1)), y: \(pMinY)..\(pMaxY) (h: \(pMaxY - pMinY + 1))")
