import AppKit

let url = URL(fileURLWithPath: "assets/YoungerBoy.png")
guard let img = NSImage(contentsOf: url),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    exit(1)
}

var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        if rep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}

print("YoungerBoy.png bounds: x: \(minX)..\(maxX) (w: \(maxX - minX + 1)), y: \(minY)..\(maxY) (h: \(maxY - minY + 1))")
