import AppKit

let urlShot = URL(fileURLWithPath: "Anatomy Explorer/Screenshot 2026-09-29 at 9.22.14 AM.png")
let repShot = NSBitmapImageRep(data: NSImage(contentsOf: urlShot)!.tiffRepresentation!)!

for y in stride(from: 450, through: 430, by: -1) {
    for x in 40...180 {
        let c = repShot.colorAt(x: x, y: y)!
        if c.redComponent > 0.8 && c.greenComponent > 0.8 && c.blueComponent > 0.8 {
            let normY = Double(y - 25) * (681.0 / 426.0)
            let normX = Double(x - 43) * (220.0 / 136.0)
            print("Last foot bone in shot: shot(x=\(x), y=\(y)) -> norm(x=\(normX), y=\(normY))")
            exit(0)
        }
    }
}
