import AppKit

let urlSolo = URL(fileURLWithPath: "assets/Character_OlderBoy_Solo.png")
if let img = NSImage(contentsOf: urlSolo), let rep = NSBitmapImageRep(data: img.tiffRepresentation!) {
    print("Solo size: \(rep.pixelsWide) x \(rep.pixelsHigh)")
    var nonZeroAlpha = 0
    for y in 0..<rep.pixelsHigh {
        for x in 0..<rep.pixelsWide {
            let c = rep.colorAt(x: x, y: y)!
            if c.alphaComponent > 0.05 { nonZeroAlpha += 1 }
        }
    }
    print("Non zero alpha pixels: \(nonZeroAlpha)")
} else {
    print("Could not load assets/Character_OlderBoy_Solo.png")
}
