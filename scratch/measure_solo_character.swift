import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let repSolo = NSBitmapImageRep(data: NSImage(contentsOf: urlSolo)!.tiffRepresentation!)!

print("Character_OlderBoy_Solo.png profile:")
for y in stride(from: 30, through: 250, by: 10) {
    var minX = 999, maxX = -1
    for x in 0..<repSolo.pixelsWide {
        let c = repSolo.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.1 {
            minX = min(minX, x)
            maxX = max(maxX, x)
        }
    }
    if minX <= maxX {
        print(String(format: "y=%3d (cy=%4.1f%%): x=%3d..%3d (w=%3d, cx=%4.1f%%)", y, Double(y)/6.81, minX, maxX, maxX - minX + 1, Double(minX + maxX)/2.0 / 2.2))
    } else {
        print("y=\(y): none")
    }
}
