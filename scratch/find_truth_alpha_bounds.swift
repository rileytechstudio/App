import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

var minX = rep.pixelsWide, maxX = 0, minY = rep.pixelsHigh, maxY = 0
for y in 0..<rep.pixelsHigh {
    for x in 0..<rep.pixelsWide {
        let c = rep.colorAt(x: x, y: y)!
        if c.alphaComponent > 0.05 {
            minX = min(minX, x)
            maxX = max(maxX, x)
            minY = min(minY, y)
            maxY = max(maxY, y)
        }
    }
}
print("Non-transparent bounding box in media_1790692100225.png:")
print("x: \(minX)..\(maxX) (width: \(maxX - minX + 1))")
print("y: \(minY)..\(maxY) (height: \(maxY - minY + 1))")
