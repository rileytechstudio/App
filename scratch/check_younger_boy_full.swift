import AppKit

let url = URL(fileURLWithPath: "assets/YoungerBoy.png")
let img = NSImage(contentsOfFile: url.path)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

print("YoungerBoy.png size: \(rep.pixelsWide) x \(rep.pixelsHigh)")

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
print("Non-transparent content bounds in YoungerBoy.png:")
print("x: [\(minX)..\(maxX)], y: [\(minY)..\(maxY)]")
print("Width: \(maxX - minX + 1), Height: \(maxY - minY + 1)")
print("Aspect: \(Double(maxX - minX + 1) / Double(maxY - minY + 1))")

