import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    print("Failed to load")
    exit(1)
}

print("Width: \(rep.pixelsWide), Height: \(rep.pixelsHigh)")
var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
var nonTransparent = 0

for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let color = rep.colorAt(x: x, y: y)!
        if color.alphaComponent > 0.05 {
            nonTransparent += 1
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}

print("Non-transparent pixels: \(nonTransparent)")
print("Bounding box: x: \(minX)..\(maxX) (width \(maxX - minX + 1)), y: \(minY)..\(maxY) (height \(maxY - minY + 1))")
let corner = rep.colorAt(x: 0, y: 0)!
print("Corner (0,0) alpha: \(corner.alphaComponent), r: \(corner.redComponent), g: \(corner.greenComponent), b: \(corner.blueComponent)")
