import AppKit

let url = URL(fileURLWithPath: "assets/Character_YoungerBoy_Solo.png")
let image = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!

var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let alpha = rep.colorAt(x: x, y: y)!.alphaComponent
        if alpha > 0.05 {
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }
    }
}
print("Character_YoungerBoy_Solo bounds: minX: \(minX), maxX: \(maxX), minY: \(minY), maxY: \(maxY)")
print("Width: \(maxX - minX + 1), Height: \(maxY - minY + 1)")
