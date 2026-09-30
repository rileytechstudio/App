import AppKit

let urlSkel = URL(fileURLWithPath: "Anatomy Explorer/Older Boy Skeleton.png")
let repSkel = NSBitmapImageRep(data: NSImage(contentsOf: urlSkel)!.tiffRepresentation!)!

// Scan around x: 740..850, y: 440..530 in Older Boy Skeleton.png
// Find all non-purple pixels:
// Purple background is roughly r ~ 0.35..0.45, g ~ 0.20..0.30, b ~ 0.60..0.75
var darkCount = 0
for y in 440...530 {
    for x in 740...860 {
        let c = repSkel.colorAt(x: x, y: y)!
        let r = c.redComponent, g = c.greenComponent, b = c.blueComponent
        // Is it part of the skull?
        // Let's check purple background:
        let isPurpleBg = (b > 0.6 && r > 0.30 && r < 0.45 && g > 0.18 && g < 0.30)
        let isDark = (r < 0.35 && g < 0.35 && b < 0.40)
        let isBlue = (b > 0.38 && g > 0.32 && g > r + 0.03)
        let isWhite = (r > 0.78 && g > 0.78 && b > 0.78)
        
        if !isPurpleBg && !isWhite && !isBlue {
            print(String(format: "Other pixel at (%d, %d): r=%.2f, g=%.2f, b=%.2f (isDark=%@)", x, y, r, g, b, isDark ? "YES" : "NO"))
            darkCount += 1
            if darkCount > 15 { break }
        }
    }
    if darkCount > 15 { break }
}
