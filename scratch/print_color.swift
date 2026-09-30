import AppKit

let url = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let img = NSImage(contentsOf: url)!
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!

for y in stride(from: 10, to: rep.pixelsHigh, by: 50) {
    let c = rep.colorAt(x: 10, y: y)!
    print(String(format: "y=%d: r:%.3f, g:%.3f, b:%.3f", y, c.redComponent, c.greenComponent, c.blueComponent))
}
