import AppKit

let path = "scratch/test_shift_dx-20_dy+24.png"
guard let img = NSImage(contentsOf: URL(fileURLWithPath: path)),
      let rep = NSBitmapImageRep(data: img.tiffRepresentation!) else {
    print("Failed to load \(path)")
    exit(1)
}

print("Loaded \(path): \(rep.pixelsWide) x \(rep.pixelsHigh)")
var count = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        if rep.colorAt(x: x, y: y)!.alphaComponent > 0.1 {
            count += 1
        }
    }
}
print("Non-transparent pixels: \(count)")
