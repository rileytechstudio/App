import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
let repSolo = NSBitmapImageRep(data: NSImage(contentsOf: urlSolo)!.tiffRepresentation!)!

var minX = repSolo.pixelsWide, maxX = 0, minY = repSolo.pixelsHigh, maxY = 0
for y in 0..<repSolo.pixelsHigh {
    for x in 0..<repSolo.pixelsWide {
        let c = repSolo.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}
print("Character_OlderBoy_Solo.png character bbox:")
print("x: \(minX)..\(maxX) (w: \(maxX - minX + 1))")
print("y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")
