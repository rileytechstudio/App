import AppKit

let shotUrl = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let shotRep = NSBitmapImageRep(data: NSImage(contentsOf: shotUrl)!.tiffRepresentation!)!

// In screenshot, let's find the skull bounds precisely.
// Skull cranium top, back, front (teeth/chin), bottom of mandible.
// Notice: the cervical spine is below the mandible.
// Mandible is at x: 100..128, y: 65..75.
// Teeth are at x: 110..128, y: 63..68.
// Cranium top is at x: 90..115, y: 33..35.
// Cranium back is at x: 81..85, y: 45..60.
// Orbit (eye) is at x: 118..124, y: 48..55.

// Let's print the colors around the jaw:
for y in 68...82 {
    var line = String(format: "y=%2d: ", y)
    for x in 100...130 {
        let c = shotRep.colorAt(x: x, y: y)!
        let isBone = (c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8)
        let isPink = (c.redComponent > 0.8 && c.greenComponent < 0.6 && c.blueComponent > 0.8)
        let isDark = (c.redComponent < 0.3 && c.blueComponent < 0.4)
        if isBone { line += "W" }
        else if isPink { line += "." }
        else if isDark { line += "D" }
        else { line += " " }
    }
    print(line)
}
