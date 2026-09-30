import AppKit

// In Older Boy Skeleton.png:
// Teeth line: let's find the front-most top tooth and back-most top tooth
let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

// In screenshot, let's find the front tooth and the jaw corner
// Let's print the teeth row in screenshot around y=77..82, x=105..135
print("Screenshot teeth scan (y=77..82):")
for y in 77...82 {
    for x in 105...135 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent > 0.85 && c.greenComponent > 0.85 && c.blueComponent > 0.85 {
            // white tooth
        }
    }
}

// In Older Boy Skeleton.png, teeth are around y=490..530, x=800..860
print("Older Boy Skeleton teeth scan:")
var teethMinX = 2000, teethMaxX = 0, teethMinY = 2000, teethMaxY = 0
for y in 490...540 {
    for x in 800...870 {
        let c = repSkel.colorAt(x: x, y: y)!
        if c.redComponent > 0.85 && c.greenComponent > 0.85 && c.blueComponent > 0.85 {
            teethMinX = min(teethMinX, x)
            teethMaxX = max(teethMaxX, x)
            teethMinY = min(teethMinY, y)
            teethMaxY = max(teethMaxY, y)
        }
    }
}
print(String(format: "Skel teeth bounds: x: %d..%d, y: %d..%d", teethMinX, teethMaxX, teethMinY, teethMaxY))

