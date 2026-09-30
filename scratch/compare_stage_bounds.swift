import AppKit

let charUrl = URL(fileURLWithPath: "assets/Younger Boy.png")
let skelUrl = URL(fileURLWithPath: "Anatomy Explorer/Younger Boy Skeleton.png")

guard let charImg = NSImage(contentsOf: charUrl),
      let charRep = NSBitmapImageRep(data: charImg.tiffRepresentation!),
      let skelImg = NSImage(contentsOf: skelUrl),
      let skelRep = NSBitmapImageRep(data: skelImg.tiffRepresentation!) else {
    exit(1)
}

print("Char size: \(charRep.pixelsWide) x \(charRep.pixelsHigh)")
print("Skel size: \(skelRep.pixelsWide) x \(skelRep.pixelsHigh)")

var cMinX = charRep.pixelsWide, cMaxX = 0, cMinY = charRep.pixelsHigh, cMaxY = 0
var sMinX = skelRep.pixelsWide, sMaxX = 0, sMinY = skelRep.pixelsHigh, sMaxY = 0

for y in 0..<charRep.pixelsHigh {
    for x in 0..<charRep.pixelsWide {
        if charRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
            cMinX = min(cMinX, x)
            cMaxX = max(cMaxX, x)
            cMinY = min(cMinY, y)
            cMaxY = max(cMaxY, y)
        }
        if skelRep.colorAt(x: x, y: y)!.alphaComponent > 0.05 {
            sMinX = min(sMinX, x)
            sMaxX = max(sMaxX, x)
            sMinY = min(sMinY, y)
            sMaxY = max(sMaxY, y)
        }
    }
}

print("Char bounds: x: \(cMinX)..\(cMaxX) (w: \(cMaxX - cMinX + 1)), y: \(cMinY)..\(cMaxY) (h: \(cMaxY - cMinY + 1))")
print("Skel bounds: x: \(sMinX)..\(sMaxX) (w: \(sMaxX - sMinX + 1)), y: \(sMinY)..\(sMaxY) (h: \(sMaxY - sMinY + 1))")

// Check overlap/containment
var skelPixels = 0
var outsidePixels = 0

for y in 0..<charRep.pixelsHigh {
    for x in 0..<charRep.pixelsWide {
        let sColor = skelRep.colorAt(x: x, y: y)!
        if sColor.alphaComponent > 0.05 {
            skelPixels += 1
            let cColor = charRep.colorAt(x: x, y: y)!
            if cColor.alphaComponent <= 0.05 {
                outsidePixels += 1
            }
        }
    }
}

print("Total skeleton pixels: \(skelPixels)")
print("Outside character pixels: \(outsidePixels) (\(Double(outsidePixels)/Double(skelPixels)*100.0)%)")
