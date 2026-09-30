import AppKit

let url = URL(fileURLWithPath: "/Users/rileytechstudio/.gemini/antigravity/brain/03b352bf-8857-45e4-8eb1-8aea0382f6fb/.user_uploaded/media_1790692100225.png")
let rep = NSBitmapImageRep(data: NSImage(contentsOf: url)!.tiffRepresentation!)!

print("Image size: \(rep.pixelsWide) x \(rep.pixelsHigh)")
// Sample background around x=50, y=50:
let c0 = rep.colorAt(x: 50, y: 50)!
print("At (50, 50): r=\(c0.redComponent), g=\(c0.greenComponent), b=\(c0.blueComponent), a=\(c0.alphaComponent)")

// Sample inside character (e.g. pink):
for y in stride(from: 200, through: 400, by: 50) {
    let c = rep.colorAt(x: 150, y: y)!
    print("At (150, \(y)): r=\(c.redComponent), g=\(c.greenComponent), b=\(c.blueComponent), a=\(c.alphaComponent)")
}
