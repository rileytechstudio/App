import AppKit

let userUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")
let assembledUrl = URL(fileURLWithPath: "assets/Skeleton_Assembled.png")

guard let userImg = NSImage(contentsOf: userUrl),
      let userRep = NSBitmapImageRep(data: userImg.tiffRepresentation!),
      let assemImg = NSImage(contentsOf: assembledUrl),
      let assemRep = NSBitmapImageRep(data: assemImg.tiffRepresentation!) else {
    exit(1)
}

print("User file: \(userRep.pixelsWide) x \(userRep.pixelsHigh)")
print("Skeleton_Assembled.png: \(assemRep.pixelsWide) x \(assemRep.pixelsHigh)")

// Skeleton_Assembled.png is 841 x 1690.
// Let's check aspect ratio:
print("Skeleton_Assembled aspect: \(Double(assemRep.pixelsWide) / Double(assemRep.pixelsHigh)) = \(841.0 / 1690.0)")

// User skeleton cropped bounds:
var minX = userRep.pixelsWide, maxX = 0, minY = userRep.pixelsHigh, maxY = 0
for y in 0..<userRep.pixelsHigh {
    for x in 0..<userRep.pixelsWide {
        if userRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}
let userW = maxX - minX + 1
let userH = maxY - minY + 1
print("User skeleton bounds: \(minX)..\(maxX) (w: \(userW)), \(minY)..\(maxY) (h: \(userH))")
print("User skeleton aspect: \(Double(userW) / Double(userH)) = \(Double(userW) / Double(userH))")
